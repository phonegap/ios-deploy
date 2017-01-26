#import "command-download.h"
#import "device.h"
#import "util.h"
#include <sys/stat.h>

void copy_file_callback(afc_connection* afc_conn_p, const char *name, int file)
{
    const char *local_name=name;
    
    if (*local_name=='/') local_name++;
    
    if (*local_name=='\0') return;
    
    if (file) {
        afc_file_ref fref;
        int err = AFCFileRefOpen(afc_conn_p,name,1,&fref);
        
        if (err) {
            fprintf(stderr,"AFCFileRefOpen(\"%s\") failed: %d\n",name,err);
            return;
        }
        
        FILE *fp = fopen(local_name,"w");
        
        if (fp==NULL) {
            fprintf(stderr,"fopen(\"%s\",\"w\") failer: %s\n",local_name,strerror(errno));
            AFCFileRefClose(afc_conn_p,fref);
            return;
        }
        
        char buf[4096];
        size_t sz=sizeof(buf);
        
        while (AFCFileRefRead(afc_conn_p,fref,buf,&sz)==0 && sz) {
            fwrite(buf,sz,1,fp);
            sz = sizeof(buf);
        }
        
        AFCFileRefClose(afc_conn_p,fref);
        fclose(fp);
    } else {
        if (mkdir(local_name,0777) && errno!=EEXIST)
            fprintf(stderr,"mkdir(\"%s\") failed: %s\n",local_name,strerror(errno));
    }
}


void download_tree(AMDeviceRef device, char* bundle_id, char* list_root, char* target_filename)
{
    service_conn_t houseFd = start_house_arrest_service(device, bundle_id);
    afc_connection* afc_conn_p = NULL;
    char *dirname = NULL;
    
    list_root = list_root? list_root : "/";
    target_filename = target_filename? target_filename : ".";
    
    NSString* targetPath = [NSString pathWithComponents:@[ @(target_filename), @(list_root)] ];
    mkdirp([targetPath stringByDeletingLastPathComponent]);
    
    if (AFCConnectionOpen(houseFd, 0, &afc_conn_p) == 0)  do {
        
        if (target_filename) {
            dirname = strdup(target_filename);
            mkdirp(@(dirname));
            if (mkdir(dirname,0777) && errno!=EEXIST) {
                fprintf(stderr,"mkdir(\"%s\") failed: %s\n",dirname,strerror(errno));
                break;
            }
            if (chdir(dirname)) {
                fprintf(stderr,"chdir(\"%s\") failed: %s\n",dirname,strerror(errno));
                break;
            }
        }
        
        read_dir(houseFd, afc_conn_p, list_root, copy_file_callback);
        
    } while(0);
    
    if (dirname) free(dirname);
    if (afc_conn_p) AFCConnectionClose(afc_conn_p);
}
