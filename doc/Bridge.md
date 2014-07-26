# Open Peer Cordova Plugin JavaScript to Native Bridge

> This page documents the inner working of the plugin. As a user of the plugin, you should not have to use any of these calls directly.
> See the [plugin API documentation](https://github.com/openpeer/op-cordova/blob/master/doc/API.md) instead

Lists of calls that can be made from JavaScript directly to the native interface, and their consequences.

## authorizeApp
Authorize the app to securely connect to open peer network

* `arguments[0]` application id
* `arguments[1]` shared secret

## initialize
Setup and initialize the open peer native SDK

## shutdown
Cleanup and shutdown the SDK

## switchCamera
If both front and rear camera are present, this will toggle the camera that is used. You can specify what camera you want to switch to

* `arguments[0]` Specify `front` or `back`. Otherwise will toggle camera

## sendMessageToPeer
Send a message to a peer using their identityURI

 * arguments[0] the message to send
 * arguments[1] identityURI of peer

Currently only one peer is expected

## sendMessageToSession
Send message to peers is a session

 * arguments[0] the message to send
 * arguments[1] sessionId

## placeCall
Place an audio or video call to a contact

 * `arguments[0]` conversation thread id/session id
 * `arguments[1]` includeVideo, boolean
 * `arguments[2]` identityURI of the contact to call

## hangupCall
Hang up the current call

## answerCall
Answer the call for the given session

 * `arguments[0]` sessionId

## startLoginProcess
Initiate the login process. When login state changes, `loginStateChange` event is fired on `OpenPeer`. The rectangle bounds for the login web view are defined using the first four arguments to this method:

 * `arguments[0]` padding top
 * `arguments[1]` padding right
 * `arguments[2]` padding bottom
 * `arguments[2]` padding left

## logout
Currently logout of all identities

## toggleSpeaker
Toggle the speaker state and return the new speaker state back to JS as boolean.
