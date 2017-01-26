
#import <XCTest/XCTest.h>
#import "ios-deploy-lib.h"

@interface TestLocations : XCTestCase

@end

@implementation TestLocations

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testDeveloperDiskImagePath {
    
    FindPathBlock findPathBlock = ^CFStringRef(CFStringRef rootPath, CFStringRef namePattern, CFStringRef expression) {
        
        return CFSTR("");
    };
    
    PathExistsBlock pathExistsBlock =  ^BOOL(CFTypeRef path) {
        if (!path) {
            return NO;
        }
        
        NSArray* fs = @[
                        @"/Applications/Xcode-8.app/Contents/Developer/Platforms/AppleTVOS.platform/DeviceSupport/1.0 (RST)/DeveloperDiskImage.dmg",
                        @"/Applications/Xcode-8.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/1.1 (RXT)/DeveloperDiskImage.dmg",
                        @"/Applications/Xcode-8.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/1.1/DeveloperDiskImage.dmg",
                        @"/Applications/Xcode-5.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/Latest/DeveloperDiskImage.dmg"
                        ];
        
        return [fs containsObject:path];
    };
    
    
    NSString* resultPath;
    
    // TEST 1 - AppleTV
    resultPath = (NSString*)
        copy_developer_disk_image_path_for_dev_path_and_home(
                                                    CFSTR("AppleTV"), // deviceClass
                                                    CFSTR("RST"), // build
                                                    CFSTR("1.0"), // version
                                                    CFSTR("/Applications/Xcode-8.app/Contents/Developer"),  // xcodeDevPath
                                                    CFSTR("/Users/me"),
                                                    findPathBlock,
                                                    pathExistsBlock
                                                    );
    XCTAssertEqualObjects(resultPath, @"/Applications/Xcode-8.app/Contents/Developer/Platforms/AppleTVOS.platform/DeviceSupport/1.0 (RST)/DeveloperDiskImage.dmg");
    
    // TEST 2 - iPhoneOS
    resultPath = (NSString*)
    copy_developer_disk_image_path_for_dev_path_and_home(
                                                         CFSTR("iPhone"), // deviceClass
                                                         CFSTR("RXT"), // build
                                                         CFSTR("1.1"), // version
                                                         CFSTR("/Applications/Xcode-8.app/Contents/Developer"),  // xcodeDevPath
                                                         CFSTR("/Users/me"),
                                                         findPathBlock,
                                                         pathExistsBlock
                                                         );
    XCTAssertEqualObjects(resultPath, @"/Applications/Xcode-8.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/1.1 (RXT)/DeveloperDiskImage.dmg");
    
    // TEST 3 - iPhoneOS (no build)
    resultPath = (NSString*)
    copy_developer_disk_image_path_for_dev_path_and_home(
                                                         CFSTR("iPhone"), // deviceClass
                                                         CFSTR(""), // build
                                                         CFSTR("1.1"), // version
                                                         CFSTR("/Applications/Xcode-8.app/Contents/Developer"),  // xcodeDevPath
                                                         CFSTR("/Users/me"),
                                                         findPathBlock,
                                                         pathExistsBlock
                                                         );
    XCTAssertEqualObjects(resultPath, @"/Applications/Xcode-8.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/1.1/DeveloperDiskImage.dmg");

    // TEST 4 - Latest (no specific version found, falls back to Latest)
    resultPath = (NSString*)
    copy_developer_disk_image_path_for_dev_path_and_home(
                                                         CFSTR("iPhone"), // deviceClass
                                                         CFSTR("JKT"), // build
                                                         CFSTR("8.1"), // version
                                                         CFSTR("/Applications/Xcode-5.app/Contents/Developer"),  // xcodeDevPath
                                                         CFSTR("/Users/me"),
                                                         findPathBlock,
                                                         pathExistsBlock
                                                         );
    XCTAssertEqualObjects(resultPath, @"/Applications/Xcode-5.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/Latest/DeveloperDiskImage.dmg");

}

- (void)testXcodePath {
    NSString* resultPath;
    
    FindPathBlock findPathBlock = ^CFStringRef(CFStringRef rootPath, CFStringRef namePattern, CFStringRef expression) {

        if (CFStringCompare(namePattern, CFSTR("3.*"), kCFCompareCaseInsensitive) == 0) {
            return CFStringCreateWithFormat(NULL, NULL, CFSTR("%@/%@"), rootPath, @"3.1");
        }
        
        return CFSTR("");
    };
    
    PathExistsBlock pathExistsBlock =  ^BOOL(CFTypeRef path) {
        if (!path) {
            return NO;
        }
        
        NSArray* fs = @[
                           @"/Applications/Xcode-7.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/1.0 (XYZ)",
                           @"/Applications/Xcode-alpha.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/3.1",
                           @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/2.0 (ABC)",
                           @"/Users/me/Library/Developer/Xcode/Platforms/iPhoneOS.platform/DeviceSupport/3.0 (DEF)"
                           ];
        
        return [fs containsObject:path];
    };
    

    // TEST 1 - xcodeDevPath exists
    resultPath = (NSString*)
        copy_xcode_path_for_dev_path_and_home(
                                              CFSTR("Platforms/iPhoneOS.platform/DeviceSupport"), // subPath
                                              CFSTR("1.0 (XYZ)"), // searchPattern
                                              CFSTR("/Applications/Xcode-7.app/Contents/Developer"), // xcodeDevPath
                                              CFSTR("/Users/me"), // homePath
                                              findPathBlock,
                                              pathExistsBlock
                                              );
    XCTAssertEqualObjects(resultPath, @"/Applications/Xcode-7.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/1.0 (XYZ)");
    
    // TEST 2 - xcodeDevPath exists, but path does not exist, we use the searchPattern
    resultPath = (NSString*)
    copy_xcode_path_for_dev_path_and_home(
                                          CFSTR("Platforms/iPhoneOS.platform/DeviceSupport"), // subPath
                                          CFSTR("3.*"), // searchPattern
                                          CFSTR("/Applications/Xcode-alpha.app/Contents/Developer"), // xcodeDevPath
                                          CFSTR("/Users/me"), // homePath
                                          findPathBlock,
                                          pathExistsBlock
                                          );
    XCTAssertEqualObjects(resultPath, @"/Applications/Xcode-alpha.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/3.1");
    
    

    // TEST 3 - xcodeDevPath does not exist, we use default /Applications/Xcode.app/Contents/Developer as base
    resultPath = (NSString*)
    copy_xcode_path_for_dev_path_and_home(
                                          CFSTR("Platforms/iPhoneOS.platform/DeviceSupport"), // subPath
                                          CFSTR("2.0 (ABC)"), // searchPattern
                                          CFSTR("/Applications/Xcode-beta.app/Contents/Developer"), // xcodeDevPath
                                          CFSTR("/Users/me"), // homePath
                                          findPathBlock,
                                          pathExistsBlock
                                          );
    XCTAssertEqualObjects(resultPath, @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/2.0 (ABC)");
    
    // TEST 4 - xcodeDevPath does not exist, and it doesn't exist in the default, so we use home ~/Library/Developer/Xcode as base
    resultPath = (NSString*)
    copy_xcode_path_for_dev_path_and_home(
                                          CFSTR("Platforms/iPhoneOS.platform/DeviceSupport"), // subPath
                                          CFSTR("3.0 (DEF)"), // searchPattern
                                          CFSTR("/Applications/Xcode-6.app/Contents/Developer"), // xcodeDevPath
                                          CFSTR("/Users/me"), // homePath
                                          findPathBlock,
                                          pathExistsBlock
                                          );
    XCTAssertEqualObjects(resultPath, @"/Users/me/Library/Developer/Xcode/Platforms/iPhoneOS.platform/DeviceSupport/3.0 (DEF)");
}

@end
