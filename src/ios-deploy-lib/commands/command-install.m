#import "command-install.h"
//#import "util.h"
//#import "device.h"
#import "logging.h"

#import <Foundation/Foundation.h>

mach_error_t transfer_callback(CFDictionaryRef dict, void* arg) {
    int percent;
    CFStringRef last_path = *((CFStringRef*)arg);
    CFStringRef status = CFDictionaryGetValue(dict, CFSTR("Status"));
    CFNumberGetValue(CFDictionaryGetValue(dict, CFSTR("PercentComplete")), kCFNumberSInt32Type, &percent);
    
    if (CFEqual(status, CFSTR("CopyingFile"))) {
        CFStringRef path = CFDictionaryGetValue(dict, CFSTR("Path"));
        
        if ((last_path == NULL || !CFEqual(path, last_path)) && !CFStringHasSuffix(path, CFSTR(".ipa"))) {
            NSLogOut(@"[%3d%%] Copying %@ to device", percent / 2, path);
        }
        
        if (last_path != NULL) {
            CFRelease(last_path);
        }
        last_path = CFStringCreateCopy(NULL, path);
    }
    
    return 0;
}

mach_error_t install_callback(CFDictionaryRef dict, void* arg) {
    int percent;
    CFStringRef status = CFDictionaryGetValue(dict, CFSTR("Status"));
    CFNumberGetValue(CFDictionaryGetValue(dict, CFSTR("PercentComplete")), kCFNumberSInt32Type, &percent);
    
    NSLogOut(@"[%3d%%] %@", (percent / 2) + 50, status);
    return 0;
}

void install(AMDeviceRef device, CFURLRef url, CFStringRef device_full_name, CFStringRef device_interface_name, char* app_path, CFStringRef last_path) {
    NSLogOut(@"------ Install phase ------");
    NSLogOut(@"[  0%%] Found %@ connected through %@, beginning install", device_full_name, device_interface_name);
    
    AMDeviceConnect(device);
    assert(AMDeviceIsPaired(device));
    check_error(AMDeviceValidatePairing(device));
    check_error(AMDeviceStartSession(device));
    
    
    // NOTE: the secure version doesn't seem to require us to start the AFC service
    service_conn_t afcFd;
    check_error(AMDeviceSecureStartService(device, CFSTR("com.apple.afc"), NULL, &afcFd));
    check_error(AMDeviceStopSession(device));
    check_error(AMDeviceDisconnect(device));
    
    CFStringRef keys[] = { CFSTR("PackageType") };
    CFStringRef values[] = { CFSTR("Developer") };
    CFDictionaryRef options = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    //assert(AMDeviceTransferApplication(afcFd, path, NULL, transfer_callback, NULL) == 0);
    check_error(AMDeviceSecureTransferPath(0, device, url, options, transfer_callback, &last_path));
    
    close(afcFd);
    
    AMDeviceConnect(device);
    assert(AMDeviceIsPaired(device));
    check_error(AMDeviceValidatePairing(device));
    check_error(AMDeviceStartSession(device));
    
    // // NOTE: the secure version doesn't seem to require us to start the installation_proxy service
    // // Although I can't find it right now, I in some code that the first param of AMDeviceSecureInstallApplication was a "dontStartInstallProxy"
    // // implying this is done for us by iOS already
    
    //service_conn_t installFd;
    //assert(AMDeviceSecureStartService(device, CFSTR("com.apple.mobile.installation_proxy"), NULL, &installFd) == 0);
    
    //mach_error_t result = AMDeviceInstallApplication(installFd, path, options, install_callback, NULL);
    check_error(AMDeviceSecureInstallApplication(0, device, url, options, install_callback, 0));
    
    // close(installFd);
    
    check_error(AMDeviceStopSession(device));
    check_error(AMDeviceDisconnect(device));
    
    CFRelease(options);
    
    NSLogOut(@"[100%%] Installed package %@", [NSString stringWithUTF8String:app_path]);
}
