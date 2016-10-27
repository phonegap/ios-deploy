
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
        
        NSString* path_ = (NSString*)path;
        NSArray* fs = @[
                           @"/Applications/Xcode-7.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/1.0 (XYZ)",
                           @"/Applications/Xcode-alpha.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/3.1",
                           @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/2.0 (ABC)",
                           @"/Users/me/Library/Developer/Xcode/Platforms/iPhoneOS.platform/DeviceSupport/3.0 (DEF)"
                           ];
        
        return [fs containsObject:path_];
    };
    

    // TEST 1 - xcodeDevPath exists
    resultPath = (NSString*)
        copy_xcode_path_for_dev_path_and_home(
                                              CFSTR("Platforms/iPhoneOS.platform/DeviceSupport") /*subPath*/,
                                              CFSTR("1.0 (XYZ)") /*search*/,
                                              CFSTR("/Applications/Xcode-7.app/Contents/Developer")/*xcodeDevPath*/,
                                              CFSTR("/Users/me")/*homePath*/,
                                              findPathBlock,
                                              pathExistsBlock
                                              );
    XCTAssertEqualObjects(resultPath, @"/Applications/Xcode-7.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/1.0 (XYZ)");
    
    // TEST 2 - xcodeDevPath exists, but path does not exist, we use the searchPattern
    resultPath = (NSString*)
    copy_xcode_path_for_dev_path_and_home(
                                          CFSTR("Platforms/iPhoneOS.platform/DeviceSupport") /*subPath*/,
                                          CFSTR("3.*") /*search*/,
                                          CFSTR("/Applications/Xcode-alpha.app/Contents/Developer")/*xcodeDevPath*/,
                                          CFSTR("/Users/me")/*homePath*/,
                                          findPathBlock,
                                          pathExistsBlock
                                          );
    XCTAssertEqualObjects(resultPath, @"/Applications/Xcode-alpha.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/3.1");
    
    

    // TEST 3 - xcodeDevPath does not exist, we use default /Applications/Xcode.app/Contents/Developer as base
    resultPath = (NSString*)
    copy_xcode_path_for_dev_path_and_home(
                                          CFSTR("Platforms/iPhoneOS.platform/DeviceSupport") /*subPath*/,
                                          CFSTR("2.0 (ABC)") /*search*/,
                                          CFSTR("/Applications/Xcode-beta.app/Contents/Developer")/*xcodeDevPath*/,
                                          CFSTR("/Users/me")/*homePath*/,
                                          findPathBlock,
                                          pathExistsBlock
                                          );
    XCTAssertEqualObjects(resultPath, @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/2.0 (ABC)");
    
    // TEST 4 - xcodeDevPath does not exist, and it doesn't exist in the default, so we use home ~/Library/Developer/Xcode as base
    resultPath = (NSString*)
    copy_xcode_path_for_dev_path_and_home(
                                          CFSTR("Platforms/iPhoneOS.platform/DeviceSupport") /*subPath*/,
                                          CFSTR("3.0 (DEF)") /*search*/,
                                          CFSTR("/Applications/Xcode-6.app/Contents/Developer")/*xcodeDevPath*/,
                                          CFSTR("/Users/me")/*homePath*/,
                                          findPathBlock,
                                          pathExistsBlock
                                          );
    XCTAssertEqualObjects(resultPath, @"/Users/me/Library/Developer/Xcode/Platforms/iPhoneOS.platform/DeviceSupport/3.0 (DEF)");
}

@end
