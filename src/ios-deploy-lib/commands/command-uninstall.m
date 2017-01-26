#import "command-uninstall.h"
//#import "util.h"
//#import "device.h"
#import "logging.h"
#import "appinfo.h"

//#import <Foundation/Foundation.h>

void uninstall(AMDeviceRef device, CFURLRef url, char* bundle_id, char* app_path) {
    NSLogOut(@"------ Uninstall phase ------");
    
    //Do we already have the bundle_id passed in via the command line? if so, use it.
    CFStringRef cf_uninstall_bundle_id = NULL;
    if (bundle_id != NULL)
    {
        cf_uninstall_bundle_id = CFStringCreateWithCString(NULL, bundle_id, kCFStringEncodingUTF8);
    } else {
        cf_uninstall_bundle_id = get_bundle_id(url);
    }
    
    if (cf_uninstall_bundle_id == NULL) {
        on_error(@"Error: Unable to get bundle id from user command or package %@.\nUninstall failed.", [NSString stringWithUTF8String:app_path]);
    } else {
        AMDeviceConnect(device);
        assert(AMDeviceIsPaired(device));
        check_error(AMDeviceValidatePairing(device));
        check_error(AMDeviceStartSession(device));
        
        int code = AMDeviceSecureUninstallApplication(0, device, cf_uninstall_bundle_id, 0, NULL, 0);
        if (code == 0) {
            NSLogOut(@"[ OK ] Uninstalled package with bundle id %@", cf_uninstall_bundle_id);
        } else {
            on_error(@"[ ERROR ] Could not uninstall package with bundle id %@", cf_uninstall_bundle_id);
        }
        check_error(AMDeviceStopSession(device));
        check_error(AMDeviceDisconnect(device));
    }
    
}
