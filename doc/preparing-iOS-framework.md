= Why iOS Framework =
This document explains the process to build, upload and reference the iOS framework for use in the cordova app. This procedure is part of mainaining the op-cordova plugin. We upload the framework containing the binary files, and add it to the pluing before installing the plugin in an app. By doing so, we save a lot of time and effort that would take to build the SDK from source. If you are interested in building the iOS framework from source and include it in your app, and include it in the plugin yourself, you can also follow this doc.

== Building the latest master == 
* Clone the iOS project, and open the SDK in xcode:
```
git clone --recursive https://github.com/openpeer/opios.git
open opios/openpeer-ios-sdk.xcodeproj
```
* Select the **HOPSDK** from the list of schemes. Connect an iOS 7.0 device (iPad, iPod, or iPhone) and select it on the build toolbar.
* Select *Product>Archive* in xcode. Depending on your machine, it may take around 1 hour to generate the archive.
* xcode will build the framework

== Making Corrections == 
For now we need to perform some additional tasks before we can compress the SDK:

*

== Upload to AWS ==

== Update the Install Script ==

