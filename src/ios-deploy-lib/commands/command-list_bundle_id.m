#import "command-list_bundle_id.h"
#import "MobileDevice.h"
#import "util.h"
#import "logging.h"

#import <Foundation/Foundation.h>


void list_bundle_id(AMDeviceRef device)
{
    AMDeviceConnect(device);
    assert(AMDeviceIsPaired(device));
    check_error(AMDeviceValidatePairing(device));
    check_error(AMDeviceStartSession(device));
    
    NSArray *a = [NSArray arrayWithObjects:@"CFBundleIdentifier", nil];
    NSDictionary *optionsDict = [NSDictionary dictionaryWithObject:a forKey:@"ReturnAttributes"];
    CFDictionaryRef options = (CFDictionaryRef)optionsDict;
    CFDictionaryRef result = nil;
    check_error(AMDeviceLookupApplications(device, options, &result));
    
    CFIndex count;
    count = CFDictionaryGetCount(result);
    const void *keys[count];
    CFDictionaryGetKeysAndValues(result, keys, NULL);
    for(int i = 0; i < count; ++i) {
        NSLogOut(@"%@", (CFStringRef)keys[i]);
    }
    
    check_error(AMDeviceStopSession(device));
    check_error(AMDeviceDisconnect(device));
}
