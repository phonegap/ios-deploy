#import "command-uninstall_only.h"
#import "logging.h"

void uninstall_app(AMDeviceRef device, char* bundle_id, char* app_path) {
    CFRetain(device); // don't know if this is necessary?
    
    NSLogOut(@"------ Uninstall phase ------");
    
    //Do we already have the bundle_id passed in via the command line? if so, use it.
    CFStringRef cf_uninstall_bundle_id = NULL;
    if (bundle_id != NULL)
    {
        cf_uninstall_bundle_id = CFStringCreateWithCString(NULL, bundle_id, kCFStringEncodingUTF8);
    } else {
        on_error(@"Error: you need to pass in the bundle id, (i.e. --bundle_id com.my.app)");
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
