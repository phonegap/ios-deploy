//
//  devices.h
//  ios-deploy
//
//  Created by Gusts Kaksis on 26/10/2016.
//  Copyright © 2016 PhoneGap. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ADD_DEVICE(model, name, sdk, arch) {CFSTR(model), CFSTR(name), CFSTR(sdk), CFSTR(arch)}

typedef struct {
    CFStringRef model;
    CFStringRef name;
    CFStringRef sdk;
    CFStringRef arch;
} device_desc;

#define UNKNOWN_DEVICE_IDX 0

device_desc device_db[] = {
                          ADD_DEVICE("UNKN",   "Unknown Device",             "uknownos", "unkarch"),

                          // iPod Touch

                          ADD_DEVICE("N45AP",  "iPod Touch",                 "iphoneos", "armv7"),
                          ADD_DEVICE("N72AP",  "iPod Touch 2G",              "iphoneos", "armv7"),
                          ADD_DEVICE("N18AP",  "iPod Touch 3G",              "iphoneos", "armv7"),
                          ADD_DEVICE("N81AP",  "iPod Touch 4G",              "iphoneos", "armv7"),
                          ADD_DEVICE("N78AP",  "iPod Touch 5G",              "iphoneos", "armv7"),
                          ADD_DEVICE("N78AAP", "iPod Touch 5G",              "iphoneos", "armv7"),
                          ADD_DEVICE("N102AP", "iPod Touch 6G",              "iphoneos", "arm64"),

                          // iPad

                          ADD_DEVICE("K48AP",  "iPad",                       "iphoneos", "armv7"),
                          ADD_DEVICE("K93AP",  "iPad 2",                     "iphoneos", "armv7"),
                          ADD_DEVICE("K94AP",  "iPad 2 (GSM)",               "iphoneos", "armv7"),
                          ADD_DEVICE("K95AP",  "iPad 2 (CDMA)",              "iphoneos", "armv7"),
                          ADD_DEVICE("K93AAP", "iPad 2 (Wi-Fi, revision A)", "iphoneos", "armv7"),
                          ADD_DEVICE("J1AP",   "iPad 3",                     "iphoneos", "armv7"),
                          ADD_DEVICE("J2AP",   "iPad 3 (GSM)",               "iphoneos", "armv7"),
                          ADD_DEVICE("J2AAP",  "iPad 3 (CDMA)",              "iphoneos", "armv7"),
                          ADD_DEVICE("P101AP", "iPad 4",                     "iphoneos", "armv7s"),
                          ADD_DEVICE("P102AP", "iPad 4 (GSM)",               "iphoneos", "armv7s"),
                          ADD_DEVICE("P103AP", "iPad 4 (CDMA)",              "iphoneos", "armv7s"),
                          ADD_DEVICE("J71AP",  "iPad Air",                   "iphoneos", "arm64"),
                          ADD_DEVICE("J72AP",  "iPad Air (GSM)",             "iphoneos", "arm64"),
                          ADD_DEVICE("J73AP",  "iPad Air (CDMA)",            "iphoneos", "arm64"),
                          ADD_DEVICE("J81AP",  "iPad Air 2",                 "iphoneos", "arm64"),
                          ADD_DEVICE("J82AP",  "iPad Air 2 (GSM)",           "iphoneos", "arm64"),
                          ADD_DEVICE("J83AP",  "iPad Air 2 (CDMA)",          "iphoneos", "arm64"),
                          ADD_DEVICE("J71sAP", "iPad (2017)",                "iphoneos", "arm64"),
                          ADD_DEVICE("J71tAP", "iPad (2017)",                "iphoneos", "arm64"),
                          ADD_DEVICE("J72sAP", "iPad (2017)",                "iphoneos", "arm64"),
                          ADD_DEVICE("J72tAP", "iPad (2017)",                "iphoneos", "arm64"),

                          // iPad Pro

                          ADD_DEVICE("J98aAP",  "iPad Pro (12.9\")",         "iphoneos", "arm64"),
                          ADD_DEVICE("J99aAP",  "iPad Pro (12.9\")",         "iphoneos", "arm64"),
                          ADD_DEVICE("J120AP",  "iPad Pro 2G (12.9\")",      "iphoneos", "arm64"),
                          ADD_DEVICE("J121AP",  "iPad Pro 2G (12.9\")",      "iphoneos", "arm64"),
                          ADD_DEVICE("J127AP",  "iPad Pro (9.7\")",          "iphoneos", "arm64"),
                          ADD_DEVICE("J128AP",  "iPad Pro (9.7\")",          "iphoneos", "arm64"),
                          ADD_DEVICE("J207AP",  "iPad Pro (10.5\")",         "iphoneos", "arm64"),
                          ADD_DEVICE("J208AP",  "iPad Pro (10.5\")",         "iphoneos", "arm64"),

                          // iPad Mini

                          ADD_DEVICE("P105AP", "iPad mini",                  "iphoneos", "armv7"),
                          ADD_DEVICE("P106AP", "iPad mini (GSM)",            "iphoneos", "armv7"),
                          ADD_DEVICE("P107AP", "iPad mini (CDMA)",           "iphoneos", "armv7"),
                          ADD_DEVICE("J85AP",  "iPad mini 2",                "iphoneos", "arm64"),
                          ADD_DEVICE("J86AP",  "iPad mini 2 (GSM)",          "iphoneos", "arm64"),
                          ADD_DEVICE("J87AP",  "iPad mini 2 (CDMA)",         "iphoneos", "arm64"),
                          ADD_DEVICE("J85MAP", "iPad mini 3",                "iphoneos", "arm64"),
                          ADD_DEVICE("J86MAP", "iPad mini 3 (GSM)",          "iphoneos", "arm64"),
                          ADD_DEVICE("J87MAP", "iPad mini 3 (CDMA)",         "iphoneos", "arm64"),
                          ADD_DEVICE("J96AP",  "iPad mini 4",                "iphoneos", "arm64"),
                          ADD_DEVICE("J97AP",  "iPad mini 4 (GSM)",          "iphoneos", "arm64"),

                          // iPhone

                          ADD_DEVICE("M68AP",  "iPhone",                     "iphoneos", "armv7"),
                          ADD_DEVICE("N82AP",  "iPhone 3G",                  "iphoneos", "armv7"),
                          ADD_DEVICE("N88AP",  "iPhone 3GS",                 "iphoneos", "armv7"),
                          ADD_DEVICE("N90AP",  "iPhone 4 (GSM)",             "iphoneos", "armv7"),
                          ADD_DEVICE("N92AP",  "iPhone 4 (CDMA)",            "iphoneos", "armv7"),
                          ADD_DEVICE("N90BAP", "iPhone 4 (GSM, revision A)", "iphoneos", "armv7"),
                          ADD_DEVICE("N94AP",  "iPhone 4S",                  "iphoneos", "armv7"),
                          ADD_DEVICE("N41AP",  "iPhone 5 (GSM)",             "iphoneos", "armv7s"),
                          ADD_DEVICE("N42AP",  "iPhone 5 (Global/CDMA)",     "iphoneos", "armv7s"),
                          ADD_DEVICE("N48AP",  "iPhone 5c (GSM)",            "iphoneos", "armv7s"),
                          ADD_DEVICE("N49AP",  "iPhone 5c (Global/CDMA)",    "iphoneos", "armv7s"),
                          ADD_DEVICE("N51AP",  "iPhone 5s (GSM)",            "iphoneos", "arm64"),
                          ADD_DEVICE("N53AP",  "iPhone 5s (Global/CDMA)",    "iphoneos", "arm64"),
                          ADD_DEVICE("N61AP",  "iPhone 6 (GSM)",             "iphoneos", "arm64"),
                          ADD_DEVICE("N56AP",  "iPhone 6 Plus",              "iphoneos", "arm64"),
                          ADD_DEVICE("N71mAP", "iPhone 6s",                  "iphoneos", "arm64"),
                          ADD_DEVICE("N71AP",  "iPhone 6s",                  "iphoneos", "arm64"),
                          ADD_DEVICE("N66AP",  "iPhone 6s Plus",             "iphoneos", "arm64"),
                          ADD_DEVICE("N66mAP", "iPhone 6s Plus",             "iphoneos", "arm64"),
                          ADD_DEVICE("N69AP",  "iPhone SE",                  "iphoneos", "arm64"),
                          ADD_DEVICE("N69uAP", "iPhone SE",                  "iphoneos", "arm64"),
                          ADD_DEVICE("D10AP",  "iPhone 7",                   "iphoneos", "arm64"),
                          ADD_DEVICE("D101AP", "iPhone 7",                   "iphoneos", "arm64"),
                          ADD_DEVICE("D11AP",  "iPhone 7 Plus",              "iphoneos", "arm64"),
                          ADD_DEVICE("D111AP", "iPhone 7 Plus",              "iphoneos", "arm64"),

                          // Apple TV

                          ADD_DEVICE("K66AP",  "Apple TV 2G",                "appletvos", "armv7"),
                          ADD_DEVICE("J33AP",  "Apple TV 3G",                "appletvos", "armv7"),
                          ADD_DEVICE("J33IAP", "Apple TV 3.1G",              "appletvos", "armv7"),
                          ADD_DEVICE("J42dAP", "Apple TV 4G",                "appletvos", "arm64"),
                          };
