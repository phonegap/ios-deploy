#import "command-list.h"
#import "util.h"
#import "device.h"

#import <Foundation/Foundation.h>

void list_files(AMDeviceRef device, char* bundle_id, char* list_root)
{
    service_conn_t houseFd = start_house_arrest_service(device, bundle_id);
    
    afc_connection* afc_conn_p;
    if (AFCConnectionOpen(houseFd, 0, &afc_conn_p) == 0) {
        read_dir(houseFd, afc_conn_p, list_root?list_root:"/", NULL);
        AFCConnectionClose(afc_conn_p);
    }
}
