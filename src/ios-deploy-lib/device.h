#include "MobileDevice.h"
#import "amdevice.h"
#import "structs.h"
#import <Foundation/Foundation.h>

#define GET_FRIENDLY_MODEL_NAME(VALUE, INTERNAL_NAME, FRIENDLY_NAME)  if (kCFCompareEqualTo  == CFStringCompare(VALUE, CFSTR(INTERNAL_NAME), kCFCompareNonliteral)) { return CFSTR( FRIENDLY_NAME); };


CFStringRef copy_device_support_path_for_device(AMDeviceRef device);
CFStringRef copy_developer_disk_image_path_for_device(AMDeviceRef device);
const CFStringRef get_device_hardware_name(const AMDeviceRef device);
CFStringRef get_device_full_name(const AMDeviceRef device);
CFStringRef get_device_interface_name(const AMDeviceRef device);
void mount_developer_image(AMDeviceRef device, void (*mount_callback)(CFDictionaryRef, int));
CFSocketRef start_remote_debug_server(AMDeviceRef device, service_conn_t gdbfd, int port, AppData appData);
CFURLRef copy_device_app_url(AMDeviceRef device, CFStringRef identifier);
service_conn_t start_house_arrest_service(AMDeviceRef device, char* bundle_id);
