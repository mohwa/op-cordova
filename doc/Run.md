# Running your App
Once you have the plugin [installed](Install.md), it is time to build and use it
in your Cordova application.

## Add a Platform
Currently only `ios` is supported. If the plugin is already installed when you
add a platform, you will see a welcome message
```
$ cordova platform add ios
Creating ios project...
Installing "org.openpeer.cordova" for ios
Welcome to OpenPeer Cordova Plugin!
```

## Run You App
Now that you have installed the plugin into your Cordova application, you
just need to follow these steps to build and run your application whenever
you make a modification

1) Connect your iPad, iPod, or iPhone using a USB cable to your Mac
> Note on using a real device:
> Open Peer uses a native media stack and as a result the plugin can only run
> on an actual device since the simulator is not capable of running the native stack

2) With the device connected and ready for development, prepare your ios project:
`cordova prepare ios`
This will prepare the native code by creating an xcode project, installing
the plugin and copying your HTML5 application into it. This step is **optional**,
and if you have not made any changes to your app, you can skip the `prepare` command

2) Run your app on the device
`cordova run ios`

3) Thats it! this will compile your app, then install it on the device and
opens your app automatically when ready

> If you run into any problems with this workflow, please feel free to
> open an issue or get in touch with us
