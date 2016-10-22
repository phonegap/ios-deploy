#import "util.h"
#include <sys/stat.h>
#include "logging.h"

NSString* getUUID() {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef str = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return [(NSString*)str autorelease];
}

BOOL mkdirp(NSString* path) {
    NSError* error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:&error];
    return success;
}

char* MYCFStringCopyUTF8String(CFStringRef aString) {
    if (aString == NULL) {
        return NULL;
    }
    
    CFIndex length = CFStringGetLength(aString);
    CFIndex maxSize =
    CFStringGetMaximumSizeForEncoding(length,
                                      kCFStringEncodingUTF8);
    char *buffer = (char *)malloc(maxSize);
    if (CFStringGetCString(aString, buffer, maxSize,
                           kCFStringEncodingUTF8)) {
        return buffer;
    }
    return NULL;
}

char const* get_filename_from_path(char const* path)
{
    char const*ptr = path + strlen(path);
    while (ptr > path)
    {
        if (*ptr == '/')
            break;
        --ptr;
    }
    if (ptr+1 >= path+strlen(path))
        return NULL;
    if (ptr == path)
        return ptr;
    return ptr+1;
}

void* read_file_to_memory(char const * path, size_t* file_size)
{
    struct stat buf;
    int err = stat(path, &buf);
    if (err < 0)
    {
        return NULL;
    }
    
    *file_size = buf.st_size;
    FILE* fd = fopen(path, "r");
    char* content = malloc(*file_size);
    if (*file_size != 0 && fread(content, *file_size, 1, fd) != 1)
    {
        fclose(fd);
        return NULL;
    }
    fclose(fd);
    return content;
}

BOOL path_exists(CFTypeRef path) {
    if (CFGetTypeID(path) == CFStringGetTypeID()) {
        CFURLRef url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, true);
        BOOL result = CFURLResourceIsReachable(url, NULL);
        CFRelease(url);
        return result;
    } else if (CFGetTypeID(path) == CFURLGetTypeID()) {
        return CFURLResourceIsReachable(path, NULL);
    } else {
        return NO;
    }
}

void read_dir(service_conn_t afcFd, afc_connection* afc_conn_p, const char* dir,
              void(*callback)(afc_connection *conn,const char *dir,int file))
{
    char *dir_ent;
    
    afc_connection afc_conn;
    if (!afc_conn_p) {
        afc_conn_p = &afc_conn;
        AFCConnectionOpen(afcFd, 0, &afc_conn_p);
    }
    
    afc_dictionary* afc_dict_p;
    char *key, *val;
    int not_dir = 0;
    
    unsigned int code = AFCFileInfoOpen(afc_conn_p, dir, &afc_dict_p);
    if (code != 0) {
        // there was a problem reading or opening the file to get info on it, abort
        return;
    }
    
    while((AFCKeyValueRead(afc_dict_p,&key,&val) == 0) && key && val) {
        if (strcmp(key,"st_ifmt")==0) {
            not_dir = strcmp(val,"S_IFDIR");
            break;
        }
    }
    AFCKeyValueClose(afc_dict_p);
    
    if (not_dir) {
        NSLogOut(@"%@", [NSString stringWithUTF8String:dir]);
    } else {
        NSLogOut(@"%@/", [NSString stringWithUTF8String:dir]);
    }
    
    if (not_dir) {
        if (callback) (*callback)(afc_conn_p, dir, not_dir);
        return;
    }
    
    afc_directory* afc_dir_p;
    afc_error_t err = AFCDirectoryOpen(afc_conn_p, dir, &afc_dir_p);
    
    if (err != 0) {
        // Couldn't open dir - was probably a file
        return;
    } else {
        if (callback) (*callback)(afc_conn_p, dir, not_dir);
    }
    
    while(true) {
        err = AFCDirectoryRead(afc_conn_p, afc_dir_p, &dir_ent);
        
        if (err != 0 || !dir_ent)
            break;
        
        if (strcmp(dir_ent, ".") == 0 || strcmp(dir_ent, "..") == 0)
            continue;
        
        char* dir_joined = malloc(strlen(dir) + strlen(dir_ent) + 2);
        strcpy(dir_joined, dir);
        if (dir_joined[strlen(dir)-1] != '/')
            strcat(dir_joined, "/");
        strcat(dir_joined, dir_ent);
        read_dir(afcFd, afc_conn_p, dir_joined, callback);
        free(dir_joined);
    }
    
    AFCDirectoryClose(afc_conn_p, afc_dir_p);
}


