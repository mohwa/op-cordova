# Open Peer Cordova Plugin Native to JavaScript Events
List of all the event messages passed to JavaScript from native. For examples of how to use these events see the [API documentation]().

## Login Events

When there is any change in login state, `loginStateChange` event is fired on `OpenPeer` instance. The event contins `data.state` which can be one of the following:

 * `login-start`
 * `login-webview-visible`
 * `login-webview-close`
 * `login-relogin`
 * `login-finished`
 * `login-shutdown`
 * `login-error`

## Call Events
When there is a change in call state, first an `callStateChange` event is fired on `OpenPeer` instance.
The `callStateChange` event is captured by `CallManager` which then fired one of the following events on itself:

 * `call-preparing`
 * `call-incoming`
 * `call-ringing`
 * `call-ringback`
 * `call-open`
 * `call-onhold`
 * `call-closing`
 * `call-closed`

## Other OpenPeer Events

 * `shutdown`
