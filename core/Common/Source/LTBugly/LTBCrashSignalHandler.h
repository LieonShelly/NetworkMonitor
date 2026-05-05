//
//  LTBCrashSignalHandler.h
//  LTCommon
//
//  Created by Codex on 2026/5/5.
//

#ifndef LTBCrashSignalHandler_h
#define LTBCrashSignalHandler_h

void ltbugly_install_signal_handlers(const char *directory_path);
void ltbugly_update_signal_report_context(const char *context_json);

#endif /* LTBCrashSignalHandler_h */
