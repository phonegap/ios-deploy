#!/usr/bin/env node

var util = require('util');
var os = require('os');
var child_process = require('child_process');

var XCODEBUILD_MIN_VERSION = 7.0;
var XCODEBUILD_NOT_FOUND_MESSAGE = util.format('Please install Xcode version %s or greater from the Mac App Store.', XCODEBUILD_MIN_VERSION);
var TOOL = 'xcodebuild';

var xcode_version = child_process.spawn(TOOL, ['-version']),
	version_string = '';

xcode_version.stdout.on('data', function (data) {
	version_string += data;
});

xcode_version.stderr.on('data', function (data) {
	console.log('stderr: ' + data);
});

xcode_version.on('error', function (err) {
	console.log(util.format('Tool %s was not found. %s', TOOL, XCODEBUILD_NOT_FOUND_MESSAGE));
});

xcode_version.on('close', function (code) {
	if (code === 0) {
		var arr = version_string.match(/^Xcode (\d+\.\d+)/);
		var ver = arr[1];

		if (os.release() >= '15.0.0' && ver < XCODEBUILD_MIN_VERSION) {
			console.log(util.format('You need at least Xcode 7.0 when you are on OS X 10.11 El Capitan (you have version %s)', ver));
			process.exit(1);
		}

		if (ver < XCODEBUILD_MIN_VERSION) {
			console.log(util.format('%s : %s. (you have version %s)', TOOL, XCODEBUILD_NOT_FOUND_MESSAGE, ver));
		}

		if (os.release() >= '15.0.0') { // print the El Capitan warning
			console.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			console.log('!!!! WARNING: You are on OS X 10.11 El Capitan or greater, you may need to add the');
			console.log('!!!! WARNING:   `--unsafe-perm=true` flag when running `npm install`');
			console.log('!!!! WARNING:   or else it will fail.');
			console.log('!!!! WARNING: link:');
			console.log('!!!! WARNING:   https://github.com/phonegap/ios-deploy#os-x-1011-el-capitan-or-greater');
			console.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		}

	}
	process.exit(code);
});




