#include <stdio.h>
#import <Foundation/Foundation.h>

// Error codes we report on different failures, so scripts can distinguish between user app exit
// codes and our exit codes. For non app errors we use codes in reserved 128-255 range.
extern const int exitcode_error;
extern const int exitcode_app_crash;

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

void on_error(NSString* format, ...);
void on_sys_error(NSString* format, ...); // Print error message getting last errno and exit

void __NSLogOut(NSString* format, va_list valist);
void NSLogOut(NSString* format, ...);
void NSLogVerbose(NSString* format, ...);
