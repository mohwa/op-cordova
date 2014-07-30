# Building the iOS Framework
This document explains the process to build, upload and reference the iOS
framework for use in this Cordova plugin. This procedure is part of maintaining
the plugin, you dont need to do this if you are just using the plugin.
We upload the framework containing the binary files, and add it to the plugin
just after installing it in an app, by running
```
$ sh plugins/org.openpeer.cordova/download_sdk.sh
```

## Building the latest master
You can either build using the later `dev-stable` branch or the `master` branch.

* Clone the iOS project, and open the SDK in xcode:
```
git clone --recursive https://github.com/openpeer/opios.git
open opios/openpeer-ios-sdk.xcodeproj
```
* Select the **HOPSDK** from the list of schemes. Connect an iOS 7.0 device (iPad, iPod, or iPhone) and select it on the build toolbar.
* Select *Product>Archive* in xcode. Depending on your machine, it may take around 1 hour to generate the archive.
* xcode will build the framework and place it in the following path in your `DrivedData` folder:
`... opios/DerivedData/openpeer-ios-sdk/Build/Intermediates/ArchiveIntermediates/HOPSDK/BuildProductsPath/Release-iphoneos`
* Navigate to the above folder and you will find the SDK folder: `OpenpeerSDK.framework`

Place `OpenpeerSDK.framework` inside the `ios/src/` folder in the plugin installation.

## Update the Install Script
Update the reference to the file in [`download_sdk.sh` script](https://github.com/openpeer/op-cordova/blob/master/download_sdk.sh)
