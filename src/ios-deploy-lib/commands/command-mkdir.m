#import "command-mkdir.h"
#import "device.h"

void make_directory(AMDeviceRef device, char* bundle_id, char* target_filename) {
    service_conn_t houseFd = start_house_arrest_service(device, bundle_id);
    
    afc_connection afc_conn;
    afc_connection* afc_conn_p = &afc_conn;
    AFCConnectionOpen(houseFd, 0, &afc_conn_p);
    
    assert(AFCDirectoryCreate(afc_conn_p, target_filename) == 0);
    assert(AFCConnectionClose(afc_conn_p) == 0);
}
