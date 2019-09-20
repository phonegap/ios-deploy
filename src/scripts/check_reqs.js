#!/usr/bin/env node

var util = require('util');
var os = require('os');
var child_process = require('child_process');

var XCODEBUILD_NOT_FOUND_MESSAGE = 'Please install Xcode from the Mac App Store.';
var TOOL = 'xcodebuild';

var xcode_version = child_process.spawn(TOOL, ['-version']);

xcode_version.stderr.on('data', function (data) {
	console.log('stderr: ' + data);
});

xcode_version.on('error', function (err) {
	console.log(util.format('Tool %s was not found. %s', TOOL, XCODEBUILD_NOT_FOUND_MESSAGE));
});

xcode_version.on('close', function (code) {
	if (code === 0) {
		if (parseInt(os.release().split('.')[0]) >= 15) { // print the El Capitan warning
			console.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
			console.log('!!!! WARNING: You are on OS X 10.11 El Capitan or greater, you may need to add the');
			console.log('!!!! WARNING:   `--unsafe-perm=true` flag when running `npm install`');
			console.log('!!!! WARNING:   or else it will fail.');
			console.log('!!!! WARNING: link:');
			console.log('!!!! WARNING:   https://github.com/ios-control/ios-deploy#os-x-1011-el-capitan-or-greater');
			console.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		}

	}
	process.exit(code);
});




