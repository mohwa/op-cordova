# Debugging your Open Peer Cordova App
Here you will find a few tricks that should make your life as a mobile web
developer much easier.

## Debugging JavaScript
Once your app is running, you can connect to it via Safari. With the device
connected to your Mac via USB, open Safari and select *Develop>%YourDevice%>%App%*.
This will connect the debugger and you can now inspect and debug your HTML5 app

* If you dont see the *Develop* menu in Safari, you need to enable that in advance
preferences on your computer
* If you do not see your device name in the *Develop* menu, you would need
enable *JavaScript* and *WebInspector* in the *Advanced* setting for Safari on
your iPad, iPod, or iPhone.

## Native Stack Trace
In the unlikely event that you find a bug that crashes the application, you
can get an stack trace from the `(lldb)` session and attach that to your bug report.

* Go to the terminal where you run the app from, you should see `(lldb)`
* enter `po [NSThread callStackSymbols]`

This will print out the stack trace for the thread that has just crashed. This
information can be very useful in fixing the problem.

## Opening Native Project
When you run `cordova prepare` command, a project is created for each native
platform. You can open that project for debugging, or in case of ios you can
use xcode to configure provisioning profiles, the first time you run the app.
To open the xcode project, from the root of your Cordova app, run:
```
$open platforms/ios/yourCordovaAppName.xcodeproj/
```
