#import "command-upload.h"
#import "MobileDevice.h"
#import "logging.h"
#import "device.h"
#import "util.h"

void upload_single_file(AMDeviceRef device, afc_connection* afc_conn_p, NSString* sourcePath, NSString* destinationPath) {
    
    afc_file_ref file_ref;
    
    //        read_dir(houseFd, NULL, "/", NULL);
    
    size_t file_size;
    void* file_content = read_file_to_memory([sourcePath fileSystemRepresentation], &file_size);
    
    if (!file_content)
    {
        on_error(@"Could not open file: %@", sourcePath);
    }
    
    // Make sure the directory was created
    {
        NSString *dirpath = [destinationPath stringByDeletingLastPathComponent];
        check_error(AFCDirectoryCreate(afc_conn_p, [dirpath fileSystemRepresentation]));
    }
    
    
    int ret = AFCFileRefOpen(afc_conn_p, [destinationPath fileSystemRepresentation], 3, &file_ref);
    if (ret == 0x000a) {
        on_error(@"Cannot write to %@. Permission error.", destinationPath);
    }
    if (ret == 0x0009) {
        on_error(@"Target %@ is a directory.", destinationPath);
    }
    assert(ret == 0);
    assert(AFCFileRefWrite(afc_conn_p, file_ref, file_content, file_size) == 0);
    assert(AFCFileRefClose(afc_conn_p, file_ref) == 0);
    
    free(file_content);
}

void upload_dir(AMDeviceRef device, afc_connection* afc_conn_p, NSString* source, NSString* destination)
{
    check_error(AFCDirectoryCreate(afc_conn_p, [destination fileSystemRepresentation]));
    destination = [destination copy];
    for (NSString* item in [[NSFileManager defaultManager] contentsOfDirectoryAtPath: source error: nil])
    {
        NSString* sourcePath = [source stringByAppendingPathComponent: item];
        NSString* destinationPath = [destination stringByAppendingPathComponent: item];
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath: sourcePath isDirectory: &isDir];
        if (isDir)
        {
            upload_dir(device, afc_conn_p, sourcePath, destinationPath);
        }
        else
        {
            upload_single_file(device, afc_conn_p, sourcePath, destinationPath);
        }
    }
}

void upload_file(AMDeviceRef device, char* bundle_id, char* target_filename, char* upload_pathname)
{
    service_conn_t houseFd = start_house_arrest_service(device, bundle_id);
    
    afc_connection afc_conn;
    afc_connection* afc_conn_p = &afc_conn;
    AFCConnectionOpen(houseFd, 0, &afc_conn_p);
    
    //        read_dir(houseFd, NULL, "/", NULL);
    
    if (!target_filename)
    {
        target_filename = (char*)get_filename_from_path(upload_pathname);
    }
    
    NSString* sourcePath = [NSString stringWithUTF8String: upload_pathname];
    NSString* destinationPath = [NSString stringWithUTF8String: target_filename];
    
    BOOL isDir;
    bool exists = [[NSFileManager defaultManager] fileExistsAtPath: sourcePath isDirectory: &isDir];
    if (!exists)
    {
        on_error(@"Could not find file: %s", upload_pathname);
    }
    else if (isDir)
    {
        upload_dir(device, afc_conn_p, sourcePath, destinationPath);
    }
    else
    {
        upload_single_file(device, afc_conn_p, sourcePath, destinationPath);
    }
    assert(AFCConnectionClose(afc_conn_p) == 0);
}

