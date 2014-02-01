== Status: in development (not ready to test) ==

This is the current  dependencies and workflow that we are experimenting with. This may change in future
=== dependencies ===
  * xcode
  * cordova command line tools
  * op framework 

=== current workflow for iOS ===
  * clone this project
  * double click on `opios-cordova/platforms/ios/OPCordovaSample.xcodeproj to open iOS project in xcode
  * drag and drop OP iOS framework into the project navigator
  * `cordova build ios`
  * optional: emulate to test the UI (without video)
  * deploy to device
