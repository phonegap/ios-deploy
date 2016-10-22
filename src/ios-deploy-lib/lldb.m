#import "lldb.h"
#import "device.h"
#import "appinfo.h"
#import "logging.h"
#import "util.h"
#import "process.h"

#include <signal.h>

const int SIGLLDB = SIGUSR1;

#define PREP_CMDS_PATH @"/tmp/%@/fruitstrap-lldb-prep-cmds-"
#define LLDB_SHELL @"lldb -s %@"
/*
 * Startup script passed to lldb.
 * To see how xcode interacts with lldb, put this into .lldbinit:
 * log enable -v -f /Users/vargaz/lldb.log lldb all
 * log enable -v -f /Users/vargaz/gdb-remote.log gdb-remote all
 */
#define LLDB_PREP_CMDS CFSTR("\
platform select remote-ios --sysroot {symbols_path}\n\
target create \"{disk_app}\"\n\
script fruitstrap_device_app=\"{device_app}\"\n\
script fruitstrap_connect_url=\"connect://127.0.0.1:{device_port}\"\n\
command script import \"{python_file_path}\"\n\
command script add -f {python_command}.connect_command connect\n\
command script add -s asynchronous -f {python_command}.run_command run\n\
command script add -s asynchronous -f {python_command}.autoexit_command autoexit\n\
command script add -s asynchronous -f {python_command}.safequit_command safequit\n\
connect\n\
")

const char* lldb_prep_no_cmds = "";

const char* lldb_prep_interactive_cmds = "\
run\n\
";

const char* lldb_prep_noninteractive_justlaunch_cmds = "\
run\n\
safequit\n\
";

const char* lldb_prep_noninteractive_cmds = "\
run\n\
autoexit\n\
";

/*
 * Some things do not seem to work when using the normal commands like process connect/launch, so we invoke them
 * through the python interface. Also, Launch () doesn't seem to work when ran from init_module (), so we add
 * a command which can be used by the user to run it.
 */
NSString* LLDB_FRUITSTRAP_MODULE = @
#include "lldb.py.h"
;


void write_lldb_prep_cmds(AMDeviceRef device, CFURLRef disk_app_url, CLIFlags cliFlags, AppData appData) {
    CFStringRef ds_path = copy_device_support_path_for_device(device);
    CFStringRef symbols_path = CFStringCreateWithFormat(NULL, NULL, CFSTR("'%@/Symbols'"), ds_path);
    
    CFMutableStringRef cmds = CFStringCreateMutableCopy(NULL, 0, LLDB_PREP_CMDS);
    CFRange range = { 0, CFStringGetLength(cmds) };
    
    CFStringFindAndReplace(cmds, CFSTR("{symbols_path}"), symbols_path, range, 0);
    range.length = CFStringGetLength(cmds);
    
    CFStringFindAndReplace(cmds, CFSTR("{ds_path}"), ds_path, range, 0);
    range.length = CFStringGetLength(cmds);
    
    CFMutableStringRef pmodule = CFStringCreateMutableCopy(NULL, 0, (CFStringRef)LLDB_FRUITSTRAP_MODULE);
    
    CFRange rangeLLDB = { 0, CFStringGetLength(pmodule) };
    CFStringRef exitcode_app_crash_str = CFStringCreateWithFormat(NULL, NULL, CFSTR("%d"), exitcode_app_crash);
    CFStringFindAndReplace(pmodule, CFSTR("{exitcode_app_crash}"), exitcode_app_crash_str, rangeLLDB, 0);
    rangeLLDB.length = CFStringGetLength(pmodule);
    
    if (cliFlags.args) {
        CFStringRef cf_args = CFStringCreateWithCString(NULL, cliFlags.args, kCFStringEncodingUTF8);
        CFStringFindAndReplace(cmds, CFSTR("{args}"), cf_args, range, 0);
        rangeLLDB.length = CFStringGetLength(pmodule);
        CFStringFindAndReplace(pmodule, CFSTR("{args}"), cf_args, rangeLLDB, 0);
        
        //printf("write_lldb_prep_cmds:args: [%s][%s]\n", CFStringGetCStringPtr (cmds,kCFStringEncodingMacRoman),
        //    CFStringGetCStringPtr(pmodule, kCFStringEncodingMacRoman));
        CFRelease(cf_args);
    } else {
        CFStringFindAndReplace(cmds, CFSTR("{args}"), CFSTR(""), range, 0);
        CFStringFindAndReplace(pmodule, CFSTR("{args}"), CFSTR(""), rangeLLDB, 0);
        //printf("write_lldb_prep_cmds: [%s][%s]\n", CFStringGetCStringPtr (cmds,kCFStringEncodingMacRoman),
        //    CFStringGetCStringPtr(pmodule, kCFStringEncodingMacRoman));
    }
    range.length = CFStringGetLength(cmds);
    
    CFStringRef bundle_identifier = copy_disk_app_identifier(disk_app_url);
    CFURLRef device_app_url = copy_device_app_url(device, bundle_identifier);
    CFStringRef device_app_path = CFURLCopyFileSystemPath(device_app_url, kCFURLPOSIXPathStyle);
    CFStringFindAndReplace(cmds, CFSTR("{device_app}"), device_app_path, range, 0);
    range.length = CFStringGetLength(cmds);
    
    CFStringRef disk_app_path = CFURLCopyFileSystemPath(disk_app_url, kCFURLPOSIXPathStyle);
    CFStringFindAndReplace(cmds, CFSTR("{disk_app}"), disk_app_path, range, 0);
    range.length = CFStringGetLength(cmds);
    
    CFStringRef device_port = CFStringCreateWithFormat(NULL, NULL, CFSTR("%d"), cliFlags.port);
    CFStringFindAndReplace(cmds, CFSTR("{device_port}"), device_port, range, 0);
    range.length = CFStringGetLength(cmds);
    
    CFURLRef device_container_url = CFURLCreateCopyDeletingLastPathComponent(NULL, device_app_url);
    CFStringRef device_container_path = CFURLCopyFileSystemPath(device_container_url, kCFURLPOSIXPathStyle);
    CFMutableStringRef dcp_noprivate = CFStringCreateMutableCopy(NULL, 0, device_container_path);
    range.length = CFStringGetLength(dcp_noprivate);
    CFStringFindAndReplace(dcp_noprivate, CFSTR("/private/var/"), CFSTR("/var/"), range, 0);
    range.length = CFStringGetLength(cmds);
    CFStringFindAndReplace(cmds, CFSTR("{device_container}"), dcp_noprivate, range, 0);
    range.length = CFStringGetLength(cmds);
    
    CFURLRef disk_container_url = CFURLCreateCopyDeletingLastPathComponent(NULL, disk_app_url);
    CFStringRef disk_container_path = CFURLCopyFileSystemPath(disk_container_url, kCFURLPOSIXPathStyle);
    CFStringFindAndReplace(cmds, CFSTR("{disk_container}"), disk_container_path, range, 0);
    
    NSString* python_file_path = [NSString stringWithFormat:@"/tmp/%@/fruitstrap_", appData.uuid];
    mkdirp(python_file_path);
    
    NSString* python_command = @"fruitstrap_";
    if(cliFlags.device_id != NULL) {
        python_file_path = [python_file_path stringByAppendingString:[NSString stringWithUTF8String:cliFlags.device_id]];
        python_command = [python_command stringByAppendingString:[NSString stringWithUTF8String:cliFlags.device_id]];
    }
    python_file_path = [python_file_path stringByAppendingString:@".py"];
    
    CFStringFindAndReplace(cmds, CFSTR("{python_command}"), (CFStringRef)python_command, range, 0);
    range.length = CFStringGetLength(cmds);
    CFStringFindAndReplace(cmds, CFSTR("{python_file_path}"), (CFStringRef)python_file_path, range, 0);
    range.length = CFStringGetLength(cmds);
    
    CFDataRef cmds_data = CFStringCreateExternalRepresentation(NULL, cmds, kCFStringEncodingUTF8, 0);
    NSString* prep_cmds_path = [NSString stringWithFormat:PREP_CMDS_PATH, appData.uuid];
    if(cliFlags.device_id != NULL) {
        prep_cmds_path = [prep_cmds_path stringByAppendingString:[NSString stringWithUTF8String:cliFlags.device_id]];
    }
    FILE *out = fopen([prep_cmds_path UTF8String], "w");
    fwrite(CFDataGetBytePtr(cmds_data), CFDataGetLength(cmds_data), 1, out);
    // Write additional commands based on mode we're running in
    const char* extra_cmds;
    if (!cliFlags.interactive)
    {
        if (cliFlags.justlaunch)
            extra_cmds = lldb_prep_noninteractive_justlaunch_cmds;
        else
            extra_cmds = lldb_prep_noninteractive_cmds;
    }
    else if (cliFlags.nostart)
        extra_cmds = lldb_prep_no_cmds;
    else
        extra_cmds = lldb_prep_interactive_cmds;
    fwrite(extra_cmds, strlen(extra_cmds), 1, out);
    fclose(out);
    
    CFDataRef pmodule_data = CFStringCreateExternalRepresentation(NULL, pmodule, kCFStringEncodingUTF8, 0);
    
    out = fopen([python_file_path UTF8String], "w");
    fwrite(CFDataGetBytePtr(pmodule_data), CFDataGetLength(pmodule_data), 1, out);
    fclose(out);
    
    CFRelease(cmds);
    if (ds_path != NULL) CFRelease(ds_path);
    CFRelease(bundle_identifier);
    CFRelease(device_app_url);
    CFRelease(device_app_path);
    CFRelease(disk_app_path);
    CFRelease(device_container_url);
    CFRelease(device_container_path);
    CFRelease(dcp_noprivate);
    CFRelease(disk_container_url);
    CFRelease(disk_container_path);
    CFRelease(cmds_data);
}

AppData setup_lldb(AMDeviceRef device, CFURLRef url, CLIFlags cliFlags, AppData appData) {
    AppData retVal;
    CFStringRef device_full_name = get_device_full_name(device),
    device_interface_name = get_device_interface_name(device);
    
    AMDeviceConnect(device);
    assert(AMDeviceIsPaired(device));
    check_error(AMDeviceValidatePairing(device));
    check_error(AMDeviceStartSession(device));
    
    NSLogOut(@"------ Debug phase ------");
    
    if(AMDeviceGetInterfaceType(device) == 2)
    {
        NSLogOut(@"Cannot debug %@ over %@.", device_full_name, device_interface_name);
        exit(0);
    }
    
    NSLogOut(@"Starting debug of %@ connected through %@...", device_full_name, device_interface_name);
    
    mount_developer_image(device, appData.mount_callback);      // put debugserver on the device
    retVal.serverSocket = start_remote_debug_server(device, appData.gdbfd, cliFlags.port, appData);  // start debugserver
    write_lldb_prep_cmds(device, url, cliFlags, appData);   // dump the necessary lldb commands into a file
    
    CFRelease(url);
    
    NSLogOut(@"[100%%] Connecting to remote debug server");
    NSLogOut(@"-------------------------");
    
    setpgid(getpid(), 0);
    signal(SIGHUP, killed);
    signal(SIGINT, killed);
    signal(SIGTERM, killed);
    // Need this before fork to avoid race conditions. For child process we remove this right after fork.
    signal(SIGLLDB, appData.lldb_finished_handler);
    
    retVal.parentPid = getpid();
    
    return retVal;
}

pid_t launch_debugger_and_exit(AMDeviceRef device, CFURLRef url, CLIFlags cliFlags, AppData appData) {
    pid_t child = 0;
    
    setup_lldb(device, url, cliFlags, appData);
    int pfd[2] = {-1, -1};
    if (pipe(pfd) == -1)
        perror("Pipe failed");
    int pid = fork();
    if (pid == 0) {
        signal(SIGHUP, SIG_DFL);
        signal(SIGLLDB, SIG_DFL);
        child = getpid();
        
        if (dup2(pfd[0],STDIN_FILENO) == -1)
            perror("dup2 failed");
        
        
        NSString* prep_cmds = [NSString stringWithFormat:PREP_CMDS_PATH, appData.uuid];
        NSString* lldb_shell = [NSString stringWithFormat:LLDB_SHELL, prep_cmds];
        if(cliFlags.device_id != NULL) {
            lldb_shell = [lldb_shell stringByAppendingString:[NSString stringWithUTF8String:cliFlags.device_id]];
        }
        
        int status = system([lldb_shell UTF8String]); // launch lldb
        if (status == -1)
            perror("failed launching lldb");
        
        close(pfd[0]);
        
        // Notify parent we're exiting
        kill(appData.parentPid, SIGLLDB);
        // Pass lldb exit code
        _exit(WEXITSTATUS(status));
    } else if (pid > 0) {
        child = pid;
        NSLogVerbose(@"Waiting for child [Child: %d][Parent: %d]\n", child, appData.parentPid);
    } else {
        on_sys_error(@"Fork failed");
    }
    
    return child;
}

pid_t launch_debugger(AMDeviceRef device, CFURLRef url, CLIFlags cliFlags, AppData appData) {
    setup_lldb(device, url, cliFlags, appData);
    int pid = fork();
    pid_t child;
    
    if (pid == 0) {
        signal(SIGHUP, SIG_DFL);
        signal(SIGLLDB, SIG_DFL);
        child = getpid();

        int pfd[2] = {-1, -1};
        if (isatty(STDIN_FILENO))
            // If we are running on a terminal, then we need to bring process to foreground for input
            // to work correctly on lldb's end.
            bring_process_to_foreground();
        else
            // If lldb is running in a non terminal environment, then it freaks out spamming "^D" and
            // "quit". It seems this is caused by read() on stdin returning EOF in lldb. To hack around
            // this we setup a dummy pipe on stdin, so read() would block expecting "user's" input.
            setup_dummy_pipe_on_stdin(pfd);

        NSString* lldb_shell;
        NSString* prep_cmds = [NSString stringWithFormat:PREP_CMDS_PATH, appData.uuid];
        lldb_shell = [NSString stringWithFormat:LLDB_SHELL, prep_cmds];

        if(cliFlags.device_id != NULL) {
            lldb_shell = [lldb_shell stringByAppendingString: [NSString stringWithUTF8String:cliFlags.device_id]];
        }

        int status = system([lldb_shell UTF8String]); // launch lldb
        if (status == -1)
            perror("failed launching lldb");

        close(pfd[0]);
        close(pfd[1]);

        // Notify parent we're exiting
        kill(appData.parentPid, SIGLLDB);
        // Pass lldb exit code
        _exit(WEXITSTATUS(status));
    } else if (pid > 0) {
        child = pid;
    } else {
        on_sys_error(@"Fork failed");
    }
    
    return child;
}



