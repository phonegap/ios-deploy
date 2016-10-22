#import "logging.h"

// Error codes we report on different failures, so scripts can distinguish between user app exit
// codes and our exit codes. For non app errors we use codes in reserved 128-255 range.
const int exitcode_error = 253;
const int exitcode_app_crash = 254;
BOOL gVerboseLog = 0;


// Checks for MobileDevice.framework errors, tries to print them and exits.
#define check_error(call)                                                       \
do {                                                                        \
unsigned int err = (unsigned int)call;                                  \
if (err != 0)                                                           \
{                                                                       \
const char* msg = get_error_message(err);                           \
/*on_error("Error 0x%x: %s " #call, err, msg ? msg : "unknown.");*/    \
on_error(@"Error 0x%x: %@ " #call, err, msg ? [NSString stringWithUTF8String:msg] : @"unknown."); \
}                                                                       \
} while (false);

void on_error(NSString* format, ...)
{
    va_list valist;
    va_start(valist, format);
    NSString* str = [[[NSString alloc] initWithFormat:format arguments:valist] autorelease];
    va_end(valist);
    
    NSLog(@"[ !! ] %@", str);
    
    exit(exitcode_error);
}

// Print error message getting last errno and exit
void on_sys_error(NSString* format, ...) {
    const char* errstr = strerror(errno);
    
    va_list valist;
    va_start(valist, format);
    NSString* str = [[[NSString alloc] initWithFormat:format arguments:valist] autorelease];
    va_end(valist);
    
    on_error(@"%@ : %@", str, [NSString stringWithUTF8String:errstr]);
}

void __NSLogOut(NSString* format, va_list valist) {
    NSString* str = [[[NSString alloc] initWithFormat:format arguments:valist] autorelease];
    [[str stringByAppendingString:@"\n"] writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

void NSLogOut(NSString* format, ...) {
    va_list valist;
    va_start(valist, format);
    __NSLogOut(format, valist);
    va_end(valist);
}

void setVerboseLog(BOOL verbose) {
    gVerboseLog = verbose;
}

void NSLogVerbose(NSString* format, ...) {
    // TODO:
    if (gVerboseLog) {
        va_list valist;
        va_start(valist, format);
        __NSLogOut(format, valist);
        va_end(valist);
    }
}
