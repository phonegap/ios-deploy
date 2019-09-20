IOS_CC = clang -ObjC
IOS_SDK = $(shell xcrun --sdk iphoneos --show-sdk-path)

all: clean demo.app

demo.app: demo Info.plist
	mkdir -p demo.app
	cp demo demo.app/
	cp Info.plist ResourceRules.plist demo.app/
	codesign -f -s "iPhone Developer" --entitlements Entitlements.plist demo.app

demo: demo.c
	$(IOS_CC) -g -arch armv7 -isysroot $(IOS_SDK) -framework CoreFoundation -o demo demo.c

debug: all ios-deploy
	@../build/Release/ios-deploy --debug --bundle demo.app

clean:
	@rm -rf *.app demo demo.dSYM
	
ios-deploy:
	@xcodebuild -project ../ios-deploy.xcodeproj
