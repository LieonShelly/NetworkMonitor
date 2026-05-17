//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

#ifndef LTBCrashSignalHandler_h
#define LTBCrashSignalHandler_h

void ltbugly_install_signal_handlers(const char *directory_path);
void ltbugly_update_signal_report_context(const char *context_json);

#endif /* LTBCrashSignalHandler_h */
