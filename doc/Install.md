# Installing The `op-cordova` plugin
In this section we show you how to install this plugin into your own Cordova
application.

## Dependencies
The following tools must be installed before you can develop and app with this
plugin locally
  * xcode with command line tools installed
  * [Cordova CLI](http://cordova.apache.org/docs/en/3.3.0/index.html) version **3.5** or higher

## Installing the Plugin
If you dont have an application yet, create one and navigate to it
```
$ cordova create myapp
$ cd myapp
```
Add the plugin to your project
```
$ cordova plugin add org.openpeer.cordova
```
> Note: At this stage plugin is partially installed into your project. The native
> framework for each platform is missing. You need to download the iOS SDK
> framework and extract it into the plugin folder. We have included an script
> inside the plugin that does this for you
```
$ sh plugins/org.openpeer.cordova/download_sdk.sh
```
Running the above command from the root of your project, will download the
native SDK and extract it into the plugin folder. You only need to do this once
after installing the plugin. Once the download script finishes, add the ios
platform to your project
```
$ cordova platform add ios
```
At this point, if you did not get any errors, the plugin is fully installed and
you are ready to [run your app](https://github.com/openpeer/op-cordova/blob/master/doc/Run.md).

## Checking if the plugin is installed
You can check for existence of the plugin in your project by running
```
$ cordova plugin ls
org.openpeer.cordova 0.1.0 "Open Peer Cordova Plugin"
```

## Remove the Plugin
At some point you may want to remove the plugin to install a newer version.
You can also optionally remove the whole ios project and recreate it.
Note that if you have made any changes to the ios project or the platform files
those changes will be lost and all platform specific files will be removed.
```
$ cordova platform rm ios
$ cordova plugin rm org.openpeer.cordova
Removing "org.openpeer.cordova"
```
