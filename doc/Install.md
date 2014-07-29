# Installing The `opcordova` plugin
In this section we show you how to install this plugin into your own Cordova
apps. There are two main methods to install the plugin, both of which require
the following dependencies

## Dependencies
The following tools must be installed before you can develop and app with this
plugin locally
  * xcode with command line tools installed
  * [Cordova CLI](http://cordova.apache.org/docs/en/3.3.0/index.html) version 3.5 or higher

## Method 1: Install from Plugin Registry


## Method 2: Install from Github

## Remove the Plugin
At some point you may want to remove the plugin to install a newer version
You can also optionally remove the whole ios project and recreate it.
Note that if you have made any changes to the ios project or the platform files
those changes will be lost and all platform specific files will be removed.

```
$ cordova platform rm ios
$ cordova plugin rm org.openpeer.cordova
Removing "org.openpeer.cordova"
```
