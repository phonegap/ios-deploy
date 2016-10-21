#import <Foundation/Foundation.h>


CFStringRef copy_device_support_path_x(CFStringRef deviceClass,
                                     CFStringRef build,
                                     CFStringRef version);

CFStringRef copy_xcode_path_for(CFStringRef subPath, CFStringRef search);

CFStringRef copy_xcode_dev_path();

const char *get_home();

CFStringRef find_path(CFStringRef rootPath, CFStringRef namePattern, CFStringRef expression);

Boolean path_exists(CFTypeRef path);
