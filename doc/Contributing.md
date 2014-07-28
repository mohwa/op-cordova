# Contributing




## Current development workflow for iOS
  * clone this project which is just a Cordova plugin `git clone git@github.com:openpeer/op-cordova.git`
  * `cd op-cordova`
  * run this script to download the OpenpeerSDK from S3 `sh prepare.sh`
  * go back to previous directory `cd ..`
  * clone the [test application](https://github.com/openpeer/op-cordova-test) in the same folder you cloned the plugin in `git clone git@github.com:openpeer/op-cordova-test.git`
  * Navigate into the test application folder and install the plugin:
```
  cd op-cordova-test
  cordova platform add ios
  cordova plugin add ../op-cordova
  open platforms/ios/OPCordovaSample.xcodeproj
```
  * select a device (iPad, iPhone or iPod) and press run in xcode

> Note: any modification you do to the xcode project or plugin files is temporary and will be overwritten next time you run the cordova commands to add/rm plugin or platforms. If you make modifications to plugin files in xcode and want to commit them, first run the following script to copy the plugin files back to the repo:

`shjs update_from_ios.js`

> you can then go back to `op-cordova` folder and commit your changes

  * Reinstalling the plugin

If there are strange problems, you can remove the whole ios platform folder and also the plugin, then add them back
```
cordova platform remove ios
cordova plugin remove org.openpeer.cordova
cordova platform add ios
cordova plugin add ../op-cordova
```
