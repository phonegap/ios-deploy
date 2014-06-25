ios-deploy
==========
Install and debug iPhone apps without using Xcode. Designed to work on unjailbroken devices.

## Requirements

* Mac OS X. Tested on Snow Leopard only.
* You need to have a valid iPhone development certificate installed.
* Xcode must be installed, along with the SDK for your iOS version.

## Usage

    ./ios-deploy [OPTION]...
      -d, --debug                  launch the app in GDB after installation
      -i, --id <device_id>         the id of the device to connect to
      -c, --detect                 only detect if the device is connected
      -b, --bundle <bundle.app>    the path to the app bundle to be installed
      -a, --args <args>            command line arguments to pass to the app when launching it
      -t, --timeout <timeout>      number of seconds to wait for a device to be connected
      -u, --unbuffered             don't buffer stdout
      -g, --gdbargs <args>         extra arguments to pass to GDB when starting the debugger
      -x, --gdbexec <file>         GDB commands script file
      -n, --nostart                do not start the app when debugging
      -I, --noninteractive         start in non interactive mode (quit when app crashes or exits)
      -v, --verbose                enable verbose output
      -m, --noinstall              directly start debugging without app install (-d not required) 
      -p, --port <number>          port used for device, default: 12345
      -r, --uninstall              uninstall the app before install (do not use with -m; app cache and data are cleared)       
      -l, --list <bundle id>       list files
      -V, --version                print the executable version

## Demo

* The included demo.app represents the minimum required to get code running on iOS.
* `make install` will install demo.app to the device.
* `make debug` will install demo.app and launch a GDB session.

## Notes

* With some modifications, it may be possible to use this without Xcode installed; however, you would need a copy of the relevant DeveloperDiskImage.dmg (included with Xcode). GDB would also run slower as symbols would be downloaded from the device on-the-fly.


## Listing Device Ids

Device Ids are the UDIDs of the iOS devices. From the command line, you can list device ids [this way](http://javierhz.blogspot.com/2012/06/how-to-get-udid-of-iphone-using-shell.html):

        system_profiler SPUSBDataType | sed -n -e '/iPad/,/Serial/p' -e '/iPhone/,/Serial/p' | grep "Serial Number:" | awk -F ": " '{print $2}'
