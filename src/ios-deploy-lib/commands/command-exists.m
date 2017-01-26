#import "command-exists.h"
#import "logging.h"

#import <Foundation/Foundation.h>

int app_exists(AMDeviceRef device, char* bundle_id)
{
    if (bundle_id == NULL) {
        NSLogOut(@"Bundle id is not specified.");
        return 1;
    }
    AMDeviceConnect(device);
    assert(AMDeviceIsPaired(device));
    check_error(AMDeviceValidatePairing(device));
    check_error(AMDeviceStartSession(device));
    
    CFStringRef cf_bundle_id = CFStringCreateWithCString(NULL, bundle_id, kCFStringEncodingUTF8);
    
    NSArray *a = [NSArray arrayWithObjects:@"CFBundleIdentifier", nil];
    NSDictionary *optionsDict = [NSDictionary dictionaryWithObject:a forKey:@"ReturnAttributes"];
    CFDictionaryRef options = (CFDictionaryRef)optionsDict;
    CFDictionaryRef result = nil;
    check_error(AMDeviceLookupApplications(device, options, &result));
    
    bool appExists = CFDictionaryContainsKey(result, cf_bundle_id);
    NSLogOut(@"%@", appExists ? @"true" : @"false");
    CFRelease(cf_bundle_id);
    
    check_error(AMDeviceStopSession(device));
    check_error(AMDeviceDisconnect(device));
    if (appExists) {
        return 0;
    }
    
    return -1;
}
