#import "structs.h"
#import "amdevice.h"
#import <Foundation/Foundation.h>

// Signal sent from child to parent process when LLDB finishes.
extern const int SIGLLDB;

void write_lldb_prep_cmds(AMDeviceRef device, CFURLRef disk_app_url, CLIFlags cliFlags, AppData appData);

AppData setup_lldb(AMDeviceRef device, CFURLRef url, CLIFlags cliFlags, AppData appData);
pid_t launch_debugger_and_exit(AMDeviceRef device, CFURLRef url, CLIFlags cliFlags, AppData appData);
pid_t launch_debugger(AMDeviceRef device, CFURLRef url, CLIFlags cliFlags, AppData appData);
