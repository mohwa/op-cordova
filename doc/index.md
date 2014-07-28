# org.openpeer.cordova

This plugin allows you to add peer to peer video chat using
[open peer](http://openpeer.org/) protocol to your application. For iOS support,
the plugin uses the [open peer iOS SDK](https://github.com/openpeer/opios).
Android support has not been added yet.

## How does it work?
The plugin enables you to develop a hybrid video chat application using the
native iOS open peer SDK, while creating your own application entirely in HTML5.
During a call, videos are displayed in their own native image view.
Your application can control how and where the videos are displayed using a
simple JavaScript API. Typically, you would make your UI in a transparent
web page and overlay it on top of the videos during a call.

Checkout the simple [API for this plugin](https://github.com/openpeer/op-cordova/blob/master/doc/API.md).
You will have your very own open peer powered video chat application up and
running in very little time.

>The plugin is still in early stages of development. We have release it, so that
>we can get feedback from you and add the features that matters most.
>If you use this plugin and notice that something is missing,
>please feel free to [open an issue](https://github.com/openpeer/op-cordova/issues?state=open) to let us know. Pull requests are also
>very welcome. We would love to hear from you!

Now that you are ready to get started, [install this plugin](Install.md)
into your Cordova app.
