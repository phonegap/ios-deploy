//TODO: don't copy/mount DeveloperDiskImage.dmg if it's already done - Xcode checks this somehow

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <sys/sysctl.h>
#include <stdio.h>
#include <signal.h>
#include <getopt.h>
#include <pwd.h>
#include <netinet/in.h>
#include <netinet/tcp.h>

#import "ios-deploy-lib.h"


AppData gAppData;
CLIFlags gCLIFlags;

// TODO:
void server_callback (CFSocketRef socketRef, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
    ssize_t res;

    if (CFDataGetLength (data) == 0) {
        // close the socket on which we've got end-of-file, the server_socket.
        CFSocketInvalidate(socketRef);
        CFRelease(socketRef);
        return;
    }
    res = write (CFSocketGetNative (gAppData.lldbSocket), CFDataGetBytePtr (data), CFDataGetLength (data));
}

// TODO:
void lldb_callback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info)
{
    //printf ("lldb: %s\n", CFDataGetBytePtr (data));

    if (CFDataGetLength (data) == 0) {
        // close the socket on which we've got end-of-file, the lldb_socket.
        CFSocketInvalidate(s);
        CFRelease(s);
        return;
    }
    write (gAppData.gdbfd, CFDataGetBytePtr (data), CFDataGetLength (data));
}

// TODO:
void fdvendor_callback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
    CFSocketNativeHandle socket = (CFSocketNativeHandle)(*((CFSocketNativeHandle *)data));

    assert (callbackType == kCFSocketAcceptCallBack);

    gAppData.lldbSocket = CFSocketCreateWithNative(NULL, socket, kCFSocketDataCallBack, &lldb_callback, NULL);
    int flag = 1;
    int res = setsockopt(socket, IPPROTO_TCP, TCP_NODELAY, (char *) &flag, sizeof(flag));
    assert(res == 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), CFSocketCreateRunLoopSource(NULL, gAppData.lldbSocket, 0), kCFRunLoopCommonModes);

    CFSocketInvalidate(s);
    CFRelease(s);
}

// TODO:
void lldb_finished_handler(int signum)
{
    int status = 0;
    if (waitpid(gAppData.childPid, &status, 0) == -1)
        perror("waitpid failed");
    _exit(WEXITSTATUS(status));
}

void handle_device(AMDeviceRef device) {
    NSLogVerbose(@"Already found device? %d", gAppData.found_device);

    CFStringRef found_device_id = AMDeviceCopyDeviceIdentifier(device),
                device_full_name = get_device_full_name(device),
                device_interface_name = get_device_interface_name(device);

    if (gCLIFlags.detect_only) {
        NSLogOut(@"[....] Found %@ connected through %@.", device_full_name, device_interface_name);
        gAppData.found_device = true;
        return;
    }
    if (gCLIFlags.device_id != NULL) {
        CFStringRef deviceCFSTR = CFStringCreateWithCString(NULL, gCLIFlags.device_id, kCFStringEncodingUTF8);
        if (CFStringCompare(deviceCFSTR, found_device_id, kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            gAppData.found_device = true;
            CFRelease(deviceCFSTR);
        } else {
            NSLogOut(@"Skipping %@.", device_full_name);
            return;
        }
    } else {
        gCLIFlags.device_id = MYCFStringCopyUTF8String(found_device_id);
        gAppData.found_device = true;
    }

    NSLogOut(@"[....] Using %@.", device_full_name);

    if (gCLIFlags.command_only) {
        if (strcmp("list", gCLIFlags.command) == 0) {
            list_files(device, gCLIFlags.bundle_id, gCLIFlags.list_root);
        } else if (strcmp("upload", gCLIFlags.command) == 0) {
            upload_file(device, gCLIFlags.bundle_id, gCLIFlags.target_filename, gCLIFlags.upload_pathname);
        } else if (strcmp("download", gCLIFlags.command) == 0) {
            download_tree(device, gCLIFlags.bundle_id, gCLIFlags.list_root, gCLIFlags.target_filename);
        } else if (strcmp("mkdir", gCLIFlags.command) == 0) {
            make_directory(device, gCLIFlags.bundle_id, gCLIFlags.target_filename);
        } else if (strcmp("rm", gCLIFlags.command) == 0) {
            remove_path(device, gCLIFlags.bundle_id, gCLIFlags.target_filename);
        } else if (strcmp("exists", gCLIFlags.command) == 0) {
            exit(app_exists(device, gCLIFlags.bundle_id));
        } else if (strcmp("uninstall_only", gCLIFlags.command) == 0) {
            uninstall_app(device, gCLIFlags.bundle_id, gCLIFlags.app_path);
        } else if (strcmp("list_bundle_id", gCLIFlags.command) == 0) {
            list_bundle_id(device);
        }
        exit(0);
    }

    CFRetain(device); // don't know if this is necessary?

    CFStringRef path = CFStringCreateWithCString(NULL, gCLIFlags.app_path, kCFStringEncodingUTF8);
    CFURLRef relative_url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, false);
    CFURLRef url = CFURLCopyAbsoluteURL(relative_url);
    
    CFRelease(relative_url);
    CFRelease(path);

    if (gCLIFlags.uninstall) {
        uninstall(device, url, gCLIFlags.bundle_id, gCLIFlags.app_path);
    }

    if(gCLIFlags.install) {
        install(device, url, device_full_name, device_interface_name, gCLIFlags.app_path, gAppData.last_path);
    }

    if (!gCLIFlags.debug) {
        exit(0); // no debug phase
    }

    if (gCLIFlags.justlaunch) {
        gAppData.childPid = launch_debugger_and_exit(device, url, gCLIFlags, gAppData);
    }
    else {
        gAppData.childPid = launch_debugger(device, url, gCLIFlags, gAppData);
    }
}

void mount_callback(CFDictionaryRef dict, int arg) {
    CFStringRef status = CFDictionaryGetValue(dict, CFSTR("Status"));
    
    if (CFEqual(status, CFSTR("LookingUpImage"))) {
        NSLogOut(@"[  0%%] Looking up developer disk image");
    } else if (CFEqual(status, CFSTR("CopyingImage"))) {
        NSLogOut(@"[ 30%%] Copying DeveloperDiskImage.dmg to device");
    } else if (CFEqual(status, CFSTR("MountingImage"))) {
        NSLogOut(@"[ 90%%] Mounting developer disk image");
    }
}

void device_callback(struct am_device_notification_callback_info *info, void *arg) {
    switch (info->msg) {
        case ADNCI_MSG_CONNECTED:
            if(gCLIFlags.device_id != NULL || !gCLIFlags.debug || AMDeviceGetInterfaceType(info->dev) != 2) {
                if (gCLIFlags.no_wifi && AMDeviceGetInterfaceType(info->dev) == 2)
                {
                    NSLogVerbose(@"Skipping wifi device (type: %d)", AMDeviceGetInterfaceType(info->dev));
                }
                else
                {
                    NSLogVerbose(@"Handling device type: %d", AMDeviceGetInterfaceType(info->dev));
                    handle_device(info->dev);
                }
            } else if(gAppData.best_device_match == NULL) {
                NSLogVerbose(@"Best device match: %d", AMDeviceGetInterfaceType(info->dev));
                gAppData.best_device_match = info->dev;
                CFRetain(gAppData.best_device_match);
            }
        default:
            break;
    }
}

void timeout_callback(CFRunLoopTimerRef timer, void *info) {
    if (gAppData.found_device && (!gCLIFlags.detect_only)) {
        return;
    } else if ((!gAppData.found_device) && (!gCLIFlags.detect_only))  {
        if(gAppData.best_device_match != NULL) {
            NSLogVerbose(@"Handling best device match.");
            handle_device(gAppData.best_device_match);

            CFRelease(gAppData.best_device_match);
            gAppData.best_device_match = NULL;
        }

        if(!gAppData.found_device)
            on_error(@"Timed out waiting for device.");
    }
    else
    {
      if (!gCLIFlags.debug) {
          NSLogOut(@"[....] No more devices found.");
      }

      if (gCLIFlags.detect_only && !gAppData.found_device) {
          exit(exitcode_error);
          return;
      } else {
          int mypid = getpid();
          if ((gAppData.parentPid != 0) && (gAppData.parentPid == mypid) && (gAppData.childPid != 0))
          {
              NSLogVerbose(@"Timeout. Killing child (%d) tree.", gAppData.childPid);
              kill_ptree(gAppData.childPid, SIGHUP);
          }
      }
      exit(0);
    }
}

void usage(const char* app) {
    NSLog(
        @"Usage: %@ [OPTION]...\n"
        @"  -d, --debug                  launch the app in lldb after installation\n"
        @"  -i, --id <device_id>         the id of the device to connect to\n"
        @"  -c, --detect                 only detect if the device is connected\n"
        @"  -b, --bundle <bundle.app>    the path to the app bundle to be installed\n"
        @"  -a, --args <args>            command line arguments to pass to the app when launching it\n"
        @"  -t, --timeout <timeout>      number of seconds to wait for a device to be connected\n"
        @"  -u, --unbuffered             don't buffer stdout\n"
        @"  -n, --nostart                do not start the app when debugging\n"
        @"  -I, --noninteractive         start in non interactive mode (quit when app crashes or exits)\n"
        @"  -L, --justlaunch             just launch the app and exit lldb\n"
        @"  -v, --verbose                enable verbose output\n"
        @"  -m, --noinstall              directly start debugging without app install (-d not required)\n"
        @"  -p, --port <number>          port used for device, default: dynamic\n"
        @"  -r, --uninstall              uninstall the app before install (do not use with -m; app cache and data are cleared) \n"
        @"  -9, --uninstall_only         uninstall the app ONLY. Use only with -1 <bundle_id> \n"
        @"  -1, --bundle_id <bundle id>  specify bundle id for list and upload\n"
        @"  -l, --list                   list files\n"
        @"  -o, --upload <file>          upload file\n"
        @"  -w, --download               download app tree\n"
        @"  -2, --to <target pathname>   use together with up/download file/tree. specify target\n"
        @"  -D, --mkdir <dir>            make directory on device\n"
        @"  -R, --rm <path>              remove file or directory on device (directories must be empty)\n"
        @"  -V, --version                print the executable version \n"
        @"  -e, --exists                 check if the app with given bundle_id is installed or not \n"
        @"  -B, --list_bundle_id         list bundle_id \n"
        @"  -W, --no-wifi                ignore wifi devices\n",
        [NSString stringWithUTF8String:app]);
}

void show_version() {
    NSLogOut(@"%@", @
#include "version.h"
             );
}

int main(int argc, char *argv[]) {

    gAppData.uuid = getUUID();
    
    // TODO: tidy all this untidy callback business
    gAppData.mount_callback = mount_callback;
    gAppData.lldb_finished_handler = lldb_finished_handler;
    gAppData.server_callback = server_callback;
    gAppData.fdvendor_callback = fdvendor_callback;

    gCLIFlags = parseFlags(argc, argv);
    if (gCLIFlags.error_unknown_flag) {
        usage(argv[0]);
        return 1;
    }
    if (gCLIFlags.error_show_version) {
        show_version();
        return 0;
    }
    
    if (gCLIFlags.verbose) {
        setVerboseLog(1);
    }

    if (!gCLIFlags.app_path && !gCLIFlags.detect_only && !gCLIFlags.command_only) {
        usage(argv[0]);
        on_error(@"One of -[b|c|o|l|w|D|R|e|9] is required to proceed!");
    }

    if (gCLIFlags.unbuffered) {
        setbuf(stdout, NULL);
        setbuf(stderr, NULL);
    }

    if (gCLIFlags.detect_only && gCLIFlags.timeout == 0) {
        gCLIFlags.timeout = 5;
    }

    if (gCLIFlags.app_path) {
        if (access(gCLIFlags.app_path, F_OK) != 0) {
            on_sys_error(@"Can't access app path '%@'", [NSString stringWithUTF8String:gCLIFlags.app_path]);
        }
    }

    AMDSetLogLevel(5); // otherwise syslog gets flooded with crap
    if (gCLIFlags.timeout > 0)
    {
        CFRunLoopTimerRef timer = CFRunLoopTimerCreate(NULL, CFAbsoluteTimeGetCurrent() + gCLIFlags.timeout, 0, 0, 0, timeout_callback, NULL);
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);
        NSLogOut(@"[....] Waiting up to %d seconds for iOS device to be connected", gCLIFlags.timeout);
    }
    else
    {
        NSLogOut(@"[....] Waiting for iOS device to be connected");
    }

    AMDeviceNotificationSubscribe(&device_callback, 0, 0, NULL, &(gAppData.notify));
    CFRunLoopRun();
}
