#import "appinfo.h"
#import "logging.h"

CFStringRef copy_disk_app_identifier(CFURLRef disk_app_url) {
    CFURLRef plist_url = CFURLCreateCopyAppendingPathComponent(NULL, disk_app_url, CFSTR("Info.plist"), false);
    CFReadStreamRef plist_stream = CFReadStreamCreateWithFile(NULL, plist_url);
    if (!CFReadStreamOpen(plist_stream)) {
        on_error(@"Cannot read Info.plist file: %@", plist_url);
    }
    
    CFPropertyListRef plist = CFPropertyListCreateWithStream(NULL, plist_stream, 0, kCFPropertyListImmutable, NULL, NULL);
    CFStringRef bundle_identifier = CFRetain(CFDictionaryGetValue(plist, CFSTR("CFBundleIdentifier")));
    CFReadStreamClose(plist_stream);
    
    CFRelease(plist_url);
    CFRelease(plist_stream);
    CFRelease(plist);
    
    return bundle_identifier;
}

CFStringRef get_bundle_id(CFURLRef app_url)
{
    if (app_url == NULL)
        return NULL;
    
    CFURLRef url = CFURLCreateCopyAppendingPathComponent(NULL, app_url, CFSTR("Info.plist"), false);
    
    if (url == NULL)
        return NULL;
    
    CFReadStreamRef stream = CFReadStreamCreateWithFile(NULL, url);
    CFRelease(url);
    
    if (stream == NULL)
        return NULL;
    
    CFPropertyListRef plist = NULL;
    if (CFReadStreamOpen(stream) == TRUE) {
        plist = CFPropertyListCreateWithStream(NULL, stream, 0,
                                               kCFPropertyListImmutable, NULL, NULL);
    }
    CFReadStreamClose(stream);
    CFRelease(stream);
    
    if (plist == NULL)
        return NULL;
    
    const void *value = CFDictionaryGetValue(plist, CFSTR("CFBundleIdentifier"));
    CFStringRef bundle_id = NULL;
    if (value != NULL)
        bundle_id = CFRetain(value);
    
    CFRelease(plist);
    return bundle_id;
}

