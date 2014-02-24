Status: in development (not ready to test)
==========================================

This is the current  dependencies and workflow that we are experimenting with. This may change in future
Dependencies
------------
  * xcode with command line tools installed in ios
  * [Cordova CLI](http://cordova.apache.org/docs/en/3.3.0/index.html) version 3.3 or higher
  * Open Peer iOS Framework 

Current development workflow for iOS
---------------------------------------
  * clone this project which is just a Cordova plugin
  * clone the [test application](https://github.com/openpeer/op-cordova-test) in the same folder
  
```
  cd op-cordova-test
  cordova platform add ios
  cordova plugin add ../op-cordova
  open platforms/ios/OPCordovaSample.xcodeproj
```

> Note: any modification you do to the xcode project or plugin files is temporary and will be overwritten next time you run the cordova commands to add/rm plugin or platforms

  * Copy iOS framework binary files (libcurl.a, boost.a and OpenpeerSDK) into test project 
  * configure linker (issue #6)
  * select a device (iPad, iPhone or iPod) and press run in xcode 
