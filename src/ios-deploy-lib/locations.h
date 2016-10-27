#import <Foundation/Foundation.h>


typedef BOOL (^PathExistsBlock)(CFTypeRef);
typedef CFStringRef (^FindPathBlock)(CFStringRef, CFStringRef, CFStringRef);

typedef BOOL (*PathExistsFunc)(CFTypeRef);
typedef CFStringRef (*FindPathFunc)(CFStringRef, CFStringRef, CFStringRef);

CFStringRef copy_device_support_path(
                                    CFStringRef deviceClass,
                                    CFStringRef build,
                                    CFStringRef version);
CFStringRef copy_device_support_path_for_dev_path(
                                    CFStringRef deviceClass,
                                    CFStringRef build,
                                    CFStringRef version,
                                    CFStringRef xcodeDevPath
                                    );

CFStringRef copy_developer_disk_image_path(CFStringRef deviceClass,
                                           CFStringRef build,
                                           CFStringRef version
                                           );
CFStringRef copy_developer_disk_image_path_for_dev_path(CFStringRef deviceClass,
                                           CFStringRef build,
                                           CFStringRef version,
                                           CFStringRef xcodeDevPath);

CFStringRef copy_xcode_path_for(CFStringRef subPath, CFStringRef search);
CFStringRef copy_xcode_path_for_dev_path(CFStringRef subPath, CFStringRef search, CFStringRef xcodeDevPath);
CFStringRef copy_xcode_path_for_dev_path_and_home(CFStringRef subPath, CFStringRef search, CFStringRef xcodeDevPath, CFStringRef homePath, FindPathBlock findPathBlock, PathExistsBlock pathExistsBlock);

CFStringRef copy_xcode_dev_path();

NSString* get_home();

CFStringRef find_path(CFStringRef rootPath, CFStringRef namePattern, CFStringRef expression);

CFStringRef copy_long_shot_disk_image_path();
