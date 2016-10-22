#import "flags.h"
#include <getopt.h>

CLIFlags parseFlags(int argc, char *argv[]) {
    CLIFlags flags = {};
    
    static struct option longopts[] = {
        { "debug", no_argument, NULL, 'd' },
        { "id", required_argument, NULL, 'i' },
        { "bundle", required_argument, NULL, 'b' },
        { "args", required_argument, NULL, 'a' },
        { "verbose", no_argument, NULL, 'v' },
        { "timeout", required_argument, NULL, 't' },
        { "unbuffered", no_argument, NULL, 'u' },
        { "nostart", no_argument, NULL, 'n' },
        { "noninteractive", no_argument, NULL, 'I' },
        { "justlaunch", no_argument, NULL, 'L' },
        { "detect", no_argument, NULL, 'c' },
        { "version", no_argument, NULL, 'V' },
        { "noinstall", no_argument, NULL, 'm' },
        { "port", required_argument, NULL, 'p' },
        { "uninstall", no_argument, NULL, 'r' },
        { "uninstall_only", no_argument, NULL, '9'},
        { "list", optional_argument, NULL, 'l' },
        { "bundle_id", required_argument, NULL, '1'},
        { "upload", required_argument, NULL, 'o'},
        { "download", optional_argument, NULL, 'w'},
        { "to", required_argument, NULL, '2'},
        { "mkdir", required_argument, NULL, 'D'},
        { "rm", required_argument, NULL, 'R'},
        { "exists", no_argument, NULL, 'e'},
        { "list_bundle_id", no_argument, NULL, 'B'},
        { "no-wifi", no_argument, NULL, 'W'},
        { NULL, 0, NULL, 0 },
    };
    char ch;
    
    while ((ch = getopt_long(argc, argv, "VmcdvunrILeD:R:i:b:a:t:g:x:p:1:2:o:l::w::9::B::W", longopts, NULL)) != -1)
    {
        switch (ch) {
            case 'm':
                flags.install = 0;
                flags.debug = 1;
                break;
            case 'd':
                flags.debug = 1;
                break;
            case 'i':
                flags.device_id = optarg;
                break;
            case 'b':
                flags.app_path = optarg;
                break;
            case 'a':
                flags.args = optarg;
                break;
            case 'v':
                flags.verbose = 1;
                break;
            case 't':
                flags.timeout = atoi(optarg);
                break;
            case 'u':
                flags.unbuffered = 1;
                break;
            case 'n':
                flags.nostart = 1;
                break;
            case 'I':
                flags.interactive = false;
                flags.debug = 1;
                break;
            case 'L':
                flags.interactive = 0;
                flags.justlaunch = 1;
                flags.debug = 1;
                break;
            case 'c':
                flags.detect_only = 1;
                flags.debug = 1;
                break;
            case 'V':
                flags.error_show_version = 1;
                break;
            case 'p':
                flags.port = atoi(optarg);
                break;
            case 'r':
                flags.uninstall = 1;
                break;
            case '9':
                flags.command_only = true;
                flags.command = "uninstall_only";
                break;
            case '1':
                flags.bundle_id = optarg;
                break;
            case '2':
                flags.target_filename = optarg;
                break;
            case 'o':
                flags.command_only = true;
                flags.upload_pathname = optarg;
                flags.command = "upload";
                break;
            case 'l':
                flags.command_only = true;
                flags.command = "list";
                flags.list_root = optarg;
                break;
            case 'w':
                flags.command_only = true;
                flags.command = "download";
                flags.list_root = optarg;
                break;
            case 'D':
                flags.command_only = true;
                flags.target_filename = optarg;
                flags.command = "mkdir";
                break;
            case 'R':
                flags.command_only = true;
                flags.target_filename = optarg;
                flags.command = "rm";
                break;
            case 'e':
                flags.command_only = true;
                flags.command = "exists";
                break;
            case 'B':
                flags.command_only = true;
                flags.command = "list_bundle_id";
                break;
            case 'W':
                flags.no_wifi = true;
                break;
            default:
                flags.error_unknown_flag = 1;
                break;
        }
    }
    
    return flags;
}
