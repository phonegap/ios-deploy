#import <Foundation/Foundation.h>
#import "MobileDevice.h"
#import "amdevice.h"

typedef struct {
    CFSocketRef socketRef;
    CFSocketCallBackType callbackType;
    CFDataRef address;
    const void *data;
    void *info;
    
} SocketCallbackData;


typedef struct {
    BOOL interactive;
    BOOL nostart;
    BOOL justlaunch;
    char* args;
    char* device_id;
    BOOL install;
    BOOL debug;
    BOOL verbose;
    char* app_path;
    int timeout;
    BOOL unbuffered;
    BOOL detect_only;
    int port;
    BOOL command_only;
    char* command;
    char* bundle_id;
    char* target_filename;
    BOOL uninstall;
    char* upload_pathname;
    char* list_root;
    BOOL no_wifi;
    BOOL error_unknown_flag;
    BOOL error_show_version;
    
} CLIFlags;

typedef struct {
    NSString* uuid;
    CFSocketRef serverSocket;
    CFSocketRef lldbSocket;
    pid_t parentPid;
    pid_t childPid; // lldb
    
    BOOL found_device;
    CFStringRef last_path;
    service_conn_t gdbfd;
    AMDeviceRef best_device_match;
    struct am_device_notification* notify;
    void (*lldb_finished_handler)(int);
    void (*mount_callback)(CFDictionaryRef, int);
    CFSocketCallBack server_callback;
    CFSocketCallBack fdvendor_callback;

} AppData;
