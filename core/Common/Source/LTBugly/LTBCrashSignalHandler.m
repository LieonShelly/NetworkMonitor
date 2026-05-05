//
//  LTBCrashSignalHandler.m
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

#include "LTBCrashSignalHandler.h"

#include <dlfcn.h>
#include <execinfo.h>
#include <fcntl.h>
#include <mach-o/dyld.h>
#include <pthread.h>
#include <signal.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#define LTBUGLY_MAX_PATH_LENGTH 1024
#define LTBUGLY_MAX_CONTEXT_LENGTH 131072
#define LTBUGLY_MAX_FRAME_COUNT 64

static char g_report_directory[LTBUGLY_MAX_PATH_LENGTH];
static char g_context_json[LTBUGLY_MAX_CONTEXT_LENGTH];
static volatile sig_atomic_t g_context_initialized = 0;

static void ltbugly_signal_handler(int signal_type);
static const char *ltbugly_signal_name(int signal_type);
static const char *ltbugly_signal_reason(int signal_type);
static void ltbugly_write_signal_report(int signal_type);
static void ltbugly_write_json_escaped_string(int fd, const char *value);
static void ltbugly_write_cstring(int fd, const char *value);
static void ltbugly_write_uint64(int fd, uint64_t value);
static void ltbugly_write_backtrace_json(int fd);

void ltbugly_install_signal_handlers(const char *directory_path) {
    if (directory_path == NULL) {
        return;
    }

    memset(g_report_directory, 0, sizeof(g_report_directory));
    strncpy(g_report_directory, directory_path, sizeof(g_report_directory) - 1);

    struct sigaction action;
    memset(&action, 0, sizeof(action));
    sigemptyset(&action.sa_mask);
    action.sa_handler = ltbugly_signal_handler;
    action.sa_flags = SA_RESETHAND;

    sigaction(SIGABRT, &action, NULL);
    sigaction(SIGSEGV, &action, NULL);
    sigaction(SIGBUS, &action, NULL);
    sigaction(SIGILL, &action, NULL);
    sigaction(SIGFPE, &action, NULL);
}

void ltbugly_update_signal_report_context(const char *context_json) {
    if (context_json == NULL) {
        g_context_initialized = 0;
        memset(g_context_json, 0, sizeof(g_context_json));
        return;
    }

    memset(g_context_json, 0, sizeof(g_context_json));
    strncpy(g_context_json, context_json, sizeof(g_context_json) - 1);
    g_context_initialized = 1;
}

static void ltbugly_signal_handler(int signal_type) {
    ltbugly_write_signal_report(signal_type);
    raise(signal_type);
}

static void ltbugly_write_signal_report(int signal_type) {
    if (g_report_directory[0] == '\0') {
        return;
    }

    char file_path[LTBUGLY_MAX_PATH_LENGTH];
    struct timeval tv;
    gettimeofday(&tv, NULL);
    pid_t pid = getpid();
    snprintf(
        file_path,
        sizeof(file_path),
        "%s/signal-%lld-%d.json",
        g_report_directory,
        (long long)tv.tv_sec,
        pid
    );

    int fd = open(file_path, O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd < 0) {
        return;
    }

    if (g_context_initialized && g_context_json[0] != '\0') {
        ltbugly_write_cstring(fd, g_context_json);
    } else {
        ltbugly_write_cstring(fd, "{");
    }

    if (lseek(fd, -1, SEEK_END) < 0) {
        close(fd);
        return;
    }

    ltbugly_write_cstring(fd, ",\"source\":\"signal\"");
    ltbugly_write_cstring(fd, ",\"timestamp\":");
    ltbugly_write_uint64(fd, (uint64_t)tv.tv_sec);

    ltbugly_write_cstring(fd, ",\"exception\":{");
    ltbugly_write_cstring(fd, "\"type\":");
    ltbugly_write_json_escaped_string(fd, ltbugly_signal_name(signal_type));
    ltbugly_write_cstring(fd, ",\"name\":");
    ltbugly_write_json_escaped_string(fd, ltbugly_signal_name(signal_type));
    ltbugly_write_cstring(fd, ",\"reason\":");
    ltbugly_write_json_escaped_string(fd, ltbugly_signal_reason(signal_type));
    ltbugly_write_cstring(fd, "}");

    ltbugly_write_cstring(fd, ",\"threads\":[{\"number\":");
    ltbugly_write_uint64(fd, (uint64_t)pthread_mach_thread_np(pthread_self()));
    ltbugly_write_cstring(fd, ",\"name\":");
    char thread_name[64] = {0};
    if (pthread_getname_np(pthread_self(), thread_name, sizeof(thread_name)) == 0 && thread_name[0] != '\0') {
        ltbugly_write_json_escaped_string(fd, thread_name);
    } else {
        ltbugly_write_cstring(fd, "null");
    }
    ltbugly_write_cstring(fd, ",\"crashed\":true,\"frames\":");
    ltbugly_write_backtrace_json(fd);
    ltbugly_write_cstring(fd, "}]");

    ltbugly_write_cstring(fd, "}");

    close(fd);
}

static void ltbugly_write_backtrace_json(int fd) {
    void *frames[LTBUGLY_MAX_FRAME_COUNT];
    int count = backtrace(frames, LTBUGLY_MAX_FRAME_COUNT);

    ltbugly_write_cstring(fd, "[");
    for (int i = 0; i < count; i++) {
        if (i > 0) {
            ltbugly_write_cstring(fd, ",");
        }
        Dl_info info;
        memset(&info, 0, sizeof(info));
        dladdr(frames[i], &info);

        ltbugly_write_cstring(fd, "{\"instruction_address\":");
        char address[32];
        snprintf(address, sizeof(address), "\"0x%016llx\"", (unsigned long long)(uintptr_t)frames[i]);
        ltbugly_write_cstring(fd, address);
        ltbugly_write_cstring(fd, ",\"symbol\":");
        if (info.dli_sname != NULL) {
            ltbugly_write_json_escaped_string(fd, info.dli_sname);
        } else {
            ltbugly_write_cstring(fd, "null");
        }
        ltbugly_write_cstring(fd, ",\"image_name\":");
        if (info.dli_fname != NULL) {
            const char *name = strrchr(info.dli_fname, '/');
            ltbugly_write_json_escaped_string(fd, name == NULL ? info.dli_fname : name + 1);
        } else {
            ltbugly_write_cstring(fd, "null");
        }
        ltbugly_write_cstring(fd, "}");
    }
    ltbugly_write_cstring(fd, "]");
}

static const char *ltbugly_signal_name(int signal_type) {
    switch (signal_type) {
        case SIGABRT: return "SIGABRT";
        case SIGSEGV: return "SIGSEGV";
        case SIGBUS: return "SIGBUS";
        case SIGILL: return "SIGILL";
        case SIGFPE: return "SIGFPE";
        default: return "SIGNAL";
    }
}

static const char *ltbugly_signal_reason(int signal_type) {
    switch (signal_type) {
        case SIGABRT: return "abort signal";
        case SIGSEGV: return "invalid memory access";
        case SIGBUS: return "bus error";
        case SIGILL: return "illegal instruction";
        case SIGFPE: return "floating point exception";
        default: return "unknown signal";
    }
}

static void ltbugly_write_json_escaped_string(int fd, const char *value) {
    if (value == NULL) {
        ltbugly_write_cstring(fd, "null");
        return;
    }

    ltbugly_write_cstring(fd, "\"");
    for (const char *cursor = value; *cursor != '\0'; cursor++) {
        switch (*cursor) {
            case '\\':
                ltbugly_write_cstring(fd, "\\\\");
                break;
            case '"':
                ltbugly_write_cstring(fd, "\\\"");
                break;
            case '\n':
                ltbugly_write_cstring(fd, "\\n");
                break;
            case '\r':
                ltbugly_write_cstring(fd, "\\r");
                break;
            case '\t':
                ltbugly_write_cstring(fd, "\\t");
                break;
            default:
                write(fd, cursor, 1);
                break;
        }
    }
    ltbugly_write_cstring(fd, "\"");
}

static void ltbugly_write_cstring(int fd, const char *value) {
    if (value == NULL) {
        return;
    }
    write(fd, value, strlen(value));
}

static void ltbugly_write_uint64(int fd, uint64_t value) {
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "%llu", (unsigned long long)value);
    ltbugly_write_cstring(fd, buffer);
}
