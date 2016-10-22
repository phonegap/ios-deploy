#include "MobileDevice.h"
#import <Foundation/Foundation.h>

BOOL mkdirp(NSString* path);
char* MYCFStringCopyUTF8String(CFStringRef aString);
char const* get_filename_from_path(char const* path);
void* read_file_to_memory(char const * path, size_t* file_size);
BOOL path_exists(CFTypeRef path);
void read_dir(service_conn_t afcFd, afc_connection* afc_conn_p, const char* dir,
              void(*callback)(afc_connection *conn,const char *dir,int file));
NSString* getUUID();
