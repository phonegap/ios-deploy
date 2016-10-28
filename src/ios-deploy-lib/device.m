#import "device.h"
#import "locations.h"
#import "logging.h"
#import "lldb.h"

#include <netinet/in.h>
#include <signal.h>


CFStringRef copy_device_support_path_for_device(AMDeviceRef device) {
    CFStringRef build = AMDeviceCopyValue(device, 0, CFSTR("BuildVersion"));
    CFStringRef deviceClass = AMDeviceCopyValue(device, 0, CFSTR("DeviceClass"));
    CFStringRef version = AMDeviceCopyValue(device, 0, CFSTR("ProductVersion"));
    
    CFStringRef path = copy_device_support_path(deviceClass, build, version);
    
    CFRelease(version);
    CFRelease(deviceClass);
    CFRelease(build);
    
    return path;
}

CFStringRef copy_developer_disk_image_path_for_device(AMDeviceRef device) {
    CFStringRef build = AMDeviceCopyValue(device, 0, CFSTR("BuildVersion"));
    CFStringRef deviceClass = AMDeviceCopyValue(device, 0, CFSTR("DeviceClass"));
    CFStringRef version = AMDeviceCopyValue(device, 0, CFSTR("ProductVersion"));
    
    CFStringRef path = copy_developer_disk_image_path(deviceClass, build, version);
    if (path == NULL) {
        on_error(@"Unable to locate DeveloperDiskImage.dmg. This probably means you don't have Xcode installed, you will need to launch the app manually and logging output will not be shown!");
    }
    
    CFRelease(version);
    CFRelease(deviceClass);
    CFRelease(build);
    
    return path;
}

// Please ensure that device is connected or the name will be unknown
const CFStringRef get_device_hardware_name(const AMDeviceRef device) {
    CFStringRef model = AMDeviceCopyValue(device, 0, CFSTR("HardwareModel"));
    
    if (model == NULL) {
        return CFSTR("Unknown Device");
    }
    
    // iPod Touch
    
    GET_FRIENDLY_MODEL_NAME(model, "N45AP",  "iPod Touch")
    GET_FRIENDLY_MODEL_NAME(model, "N72AP",  "iPod Touch 2G")
    GET_FRIENDLY_MODEL_NAME(model, "N18AP",  "iPod Touch 3G")
    GET_FRIENDLY_MODEL_NAME(model, "N81AP",  "iPod Touch 4G")
    GET_FRIENDLY_MODEL_NAME(model, "N78AP",  "iPod Touch 5G")
    GET_FRIENDLY_MODEL_NAME(model, "N78AAP", "iPod Touch 5G")
    
    // iPad
    
    GET_FRIENDLY_MODEL_NAME(model, "K48AP",  "iPad")
    GET_FRIENDLY_MODEL_NAME(model, "K93AP",  "iPad 2")
    GET_FRIENDLY_MODEL_NAME(model, "K94AP",  "iPad 2 (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "K95AP",  "iPad 2 (CDMA)")
    GET_FRIENDLY_MODEL_NAME(model, "K93AAP", "iPad 2 (Wi-Fi, revision A)")
    GET_FRIENDLY_MODEL_NAME(model, "J1AP",   "iPad 3")
    GET_FRIENDLY_MODEL_NAME(model, "J2AP",   "iPad 3 (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "J2AAP",  "iPad 3 (CDMA)")
    GET_FRIENDLY_MODEL_NAME(model, "P101AP", "iPad 4")
    GET_FRIENDLY_MODEL_NAME(model, "P102AP", "iPad 4 (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "P103AP", "iPad 4 (CDMA)")
    GET_FRIENDLY_MODEL_NAME(model, "J71AP",  "iPad Air")
    GET_FRIENDLY_MODEL_NAME(model, "J72AP",  "iPad Air (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "J73AP",  "iPad Air (CDMA)")
    GET_FRIENDLY_MODEL_NAME(model, "J81AP",  "iPad Air 2")
    GET_FRIENDLY_MODEL_NAME(model, "J82AP",  "iPad Air 2 (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "J83AP",  "iPad Air 2 (CDMA)")
    
    // iPad Pro
    
    GET_FRIENDLY_MODEL_NAME(model, "J98aAP",  "iPad Pro (12.9\")")
    GET_FRIENDLY_MODEL_NAME(model, "J98aAP",  "iPad Pro (12.9\")")
    GET_FRIENDLY_MODEL_NAME(model, "J127AP",  "iPad Pro (9.7\")")
    GET_FRIENDLY_MODEL_NAME(model, "J128AP",  "iPad Pro (9.7\")")
    
    // iPad Mini
    
    GET_FRIENDLY_MODEL_NAME(model, "P105AP", "iPad mini")
    GET_FRIENDLY_MODEL_NAME(model, "P106AP", "iPad mini (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "P107AP", "iPad mini (CDMA)")
    GET_FRIENDLY_MODEL_NAME(model, "J85AP",  "iPad mini 2")
    GET_FRIENDLY_MODEL_NAME(model, "J86AP",  "iPad mini 2 (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "J87AP",  "iPad mini 2 (CDMA)")
    GET_FRIENDLY_MODEL_NAME(model, "J85MAP", "iPad mini 3")
    GET_FRIENDLY_MODEL_NAME(model, "J86MAP", "iPad mini 3 (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "J87MAP", "iPad mini 3 (CDMA)")
    
    // Apple TV
    
    GET_FRIENDLY_MODEL_NAME(model, "K66AP",  "Apple TV 2G")
    GET_FRIENDLY_MODEL_NAME(model, "J33AP",  "Apple TV 3G")
    GET_FRIENDLY_MODEL_NAME(model, "J33IAP", "Apple TV 3.1G")
    GET_FRIENDLY_MODEL_NAME(model, "J42dAP", "Apple TV 4G")
    
    // iPhone
    
    GET_FRIENDLY_MODEL_NAME(model, "M68AP", "iPhone")
    GET_FRIENDLY_MODEL_NAME(model, "N82AP", "iPhone 3G")
    GET_FRIENDLY_MODEL_NAME(model, "N88AP", "iPhone 3GS")
    GET_FRIENDLY_MODEL_NAME(model, "N90AP", "iPhone 4 (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "N92AP", "iPhone 4 (CDMA)")
    GET_FRIENDLY_MODEL_NAME(model, "N90BAP", "iPhone 4 (GSM, revision A)")
    GET_FRIENDLY_MODEL_NAME(model, "N94AP", "iPhone 4S")
    GET_FRIENDLY_MODEL_NAME(model, "N41AP", "iPhone 5 (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "N42AP", "iPhone 5 (Global/CDMA)")
    GET_FRIENDLY_MODEL_NAME(model, "N48AP", "iPhone 5c (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "N49AP", "iPhone 5c (Global/CDMA)")
    GET_FRIENDLY_MODEL_NAME(model, "N51AP", "iPhone 5s (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "N53AP", "iPhone 5s (Global/CDMA)")
    GET_FRIENDLY_MODEL_NAME(model, "N61AP", "iPhone 6 (GSM)")
    GET_FRIENDLY_MODEL_NAME(model, "N56AP", "iPhone 6 Plus")
    GET_FRIENDLY_MODEL_NAME(model, "N71mAP", "iPhone 6s")
    GET_FRIENDLY_MODEL_NAME(model, "N71AP", "iPhone 6s")
    GET_FRIENDLY_MODEL_NAME(model, "N66AP", "iPhone 6s Plus")
    GET_FRIENDLY_MODEL_NAME(model, "N66mAP", "iPhone 6s Plus")
    GET_FRIENDLY_MODEL_NAME(model, "N69AP", "iPhone SE")
    GET_FRIENDLY_MODEL_NAME(model, "N69uAP", "iPhone SE")
    
    GET_FRIENDLY_MODEL_NAME(model, "D10AP", "iPhone 7")
    GET_FRIENDLY_MODEL_NAME(model, "D101AP", "iPhone 7")
    GET_FRIENDLY_MODEL_NAME(model, "D11AP", "iPhone 7 Plus")
    GET_FRIENDLY_MODEL_NAME(model, "D111AP", "iPhone 7 Plus")
    
    
    return model;
}

CFStringRef get_device_full_name(const AMDeviceRef device) {
    CFStringRef full_name = NULL,
    device_udid = AMDeviceCopyDeviceIdentifier(device),
    device_name = NULL,
    model_name = NULL;
    
    AMDeviceConnect(device);
    
    device_name = AMDeviceCopyValue(device, 0, CFSTR("DeviceName")),
    model_name = get_device_hardware_name(device);
    
    NSLogVerbose(@"Device Name: %@", device_name);
    NSLogVerbose(@"Model Name: %@", model_name);
    
    if(device_name != NULL && model_name != NULL)
    {
        full_name = CFStringCreateWithFormat(NULL, NULL, CFSTR("%@ '%@' (%@)"), model_name, device_name, device_udid);
    }
    else
    {
        full_name = CFStringCreateWithFormat(NULL, NULL, CFSTR("(%@ss)"), device_udid);
    }
    
    AMDeviceDisconnect(device);
    
    if(device_udid != NULL)
        CFRelease(device_udid);
    if(device_name != NULL)
        CFRelease(device_name);
    if(model_name != NULL)
        CFRelease(model_name);
    
    return full_name;
}

CFStringRef get_device_interface_name(const AMDeviceRef device) {
    // AMDeviceGetInterfaceType(device) 0=Unknown, 1 = Direct/USB, 2 = Indirect/WIFI
    switch(AMDeviceGetInterfaceType(device)) {
        case 1:
            return CFSTR("USB");
        case 2:
            return CFSTR("WIFI");
        default:
            return CFSTR("Unknown Connection");
    }
}

void mount_developer_image(AMDeviceRef device, void (*mount_callback)(CFDictionaryRef, int)) {
    CFStringRef ds_path = copy_device_support_path_for_device(device);
    CFStringRef image_path = copy_developer_disk_image_path_for_device(device);
    CFStringRef sig_path = CFStringCreateWithFormat(NULL, NULL, CFSTR("%@.signature"), image_path);
    
    NSLogVerbose(@"Device support path: %@", ds_path);
    NSLogVerbose(@"Developer disk image: %@", image_path);
    CFRelease(ds_path);
    
    FILE* sig = fopen(CFStringGetCStringPtr(sig_path, kCFStringEncodingMacRoman), "rb");
    void *sig_buf = malloc(128);
    assert(fread(sig_buf, 1, 128, sig) == 128);
    fclose(sig);
    CFDataRef sig_data = CFDataCreateWithBytesNoCopy(NULL, sig_buf, 128, NULL);
    CFRelease(sig_path);
    
    CFTypeRef keys[] = { CFSTR("ImageSignature"), CFSTR("ImageType") };
    CFTypeRef values[] = { sig_data, CFSTR("Developer") };
    CFDictionaryRef options = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFRelease(sig_data);
    
    int result = AMDeviceMountImage(device, image_path, options, mount_callback, 0);
    if (result == 0) {
        NSLogOut(@"[ 95%%] Developer disk image mounted successfully");
    } else if (result == 0xe8000076 /* already mounted */) {
        NSLogOut(@"[ 95%%] Developer disk image already mounted");
    } else {
        on_error(@"Unable to mount developer disk image. (%x)", result);
    }
    
    CFRelease(image_path);
    CFRelease(options);
}

CFSocketRef start_remote_debug_server(AMDeviceRef device, service_conn_t gdbfd, int port, AppData appData) {
    
    check_error(AMDeviceStartService(device, CFSTR("com.apple.debugserver"), &gdbfd, NULL));
    assert(gdbfd > 0);
    
    /*
     * The debugserver connection is through a fd handle, while lldb requires a host/port to connect, so create an intermediate
     * socket to transfer data.
     */
    CFSocketRef server_socket = CFSocketCreateWithNative (NULL, gdbfd, kCFSocketDataCallBack, (appData.server_callback), NULL);
    CFRunLoopAddSource(CFRunLoopGetMain(), CFSocketCreateRunLoopSource(NULL, server_socket, 0), kCFRunLoopCommonModes);
    
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(port);
    addr4.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    
    CFSocketRef fdvendor = CFSocketCreate(NULL, PF_INET, 0, 0, kCFSocketAcceptCallBack, (appData.fdvendor_callback), NULL);
    
    if (port) {
        int yes = 1;
        setsockopt(CFSocketGetNative(fdvendor), SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    }
    
    CFDataRef address_data = CFDataCreate(NULL, (const UInt8 *)&addr4, sizeof(addr4));
    
    CFSocketSetAddress(fdvendor, address_data);
    CFRelease(address_data);
    socklen_t addrlen = sizeof(addr4);
    int res = getsockname(CFSocketGetNative(fdvendor),(struct sockaddr *)&addr4,&addrlen);
    assert(res == 0);
    port = ntohs(addr4.sin_port);
    
    CFRunLoopAddSource(CFRunLoopGetMain(), CFSocketCreateRunLoopSource(NULL, fdvendor, 0), kCFRunLoopCommonModes);
    
    return server_socket;
}

CFURLRef copy_device_app_url(AMDeviceRef device, CFStringRef identifier) {
    CFDictionaryRef result = nil;
    
    NSArray *a = [NSArray arrayWithObjects:
                  @"CFBundleIdentifier",            // absolute must
                  @"ApplicationDSID",
                  @"ApplicationType",
                  @"CFBundleExecutable",
                  @"CFBundleDisplayName",
                  @"CFBundleIconFile",
                  @"CFBundleName",
                  @"CFBundleShortVersionString",
                  @"CFBundleSupportedPlatforms",
                  @"CFBundleURLTypes",
                  @"CodeInfoIdentifier",
                  @"Container",
                  @"Entitlements",
                  @"HasSettingsBundle",
                  @"IsUpgradeable",
                  @"MinimumOSVersion",
                  @"Path",
                  @"SignerIdentity",
                  @"UIDeviceFamily",
                  @"UIFileSharingEnabled",
                  @"UIStatusBarHidden",
                  @"UISupportedInterfaceOrientations",
                  nil];
    
    NSDictionary *optionsDict = [NSDictionary dictionaryWithObject:a forKey:@"ReturnAttributes"];
    CFDictionaryRef options = (CFDictionaryRef)optionsDict;
    
    check_error(AMDeviceLookupApplications(device, options, &result));
    
    CFDictionaryRef app_dict = CFDictionaryGetValue(result, identifier);
    assert(app_dict != NULL);
    
    CFStringRef app_path = CFDictionaryGetValue(app_dict, CFSTR("Path"));
    assert(app_path != NULL);
    
    CFURLRef url = CFURLCreateWithFileSystemPath(NULL, app_path, kCFURLPOSIXPathStyle, true);
    CFRelease(result);
    return url;
}

// Used to send files to app-specific sandbox (Documents dir)
service_conn_t start_house_arrest_service(AMDeviceRef device, char* bundle_id) {
    AMDeviceConnect(device);
    assert(AMDeviceIsPaired(device));
    check_error(AMDeviceValidatePairing(device));
    check_error(AMDeviceStartSession(device));
    
    service_conn_t houseFd;
    
    if (bundle_id == NULL) {
        on_error(@"Bundle id is not specified");
    }
    
    CFStringRef cf_bundle_id = CFStringCreateWithCString(NULL, bundle_id, kCFStringEncodingUTF8);
    if (AMDeviceStartHouseArrestService(device, cf_bundle_id, 0, &houseFd, 0) != 0)
    {
        on_error(@"Unable to find bundle with id: %@", [NSString stringWithUTF8String:bundle_id]);
    }
    
    check_error(AMDeviceStopSession(device));
    check_error(AMDeviceDisconnect(device));
    CFRelease(cf_bundle_id);
    
    return houseFd;
}
