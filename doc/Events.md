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

## Message Events

  * `message-received`

## Other OpenPeer Events

 * `shutdown`

## Passing Events from Native to JavaScript
All events are sent from native to the open peer JavaScript library using a direct call to `__CDVOP_MESSAGE_HANDLER('event-name', '{data}');`. In iOS we do the following:
```
 *  Fire an event on JS side and pass along the JSON data
 *
 *  @param event NSString* name of event to fire on JS side
 *  @param data  NSString* JSON data to pass along with event
 */
- (void) fireEventWithData:(NSString *)event data:(NSString *)data
{
    - (void) fireEventWithData:(NSString *)event data:(NSString *)data
{
    NSString *jsCall = [NSString stringWithFormat:@"__CDVOP_MESSAGE_HANDLER('%@', %@);", event, data];
    @try {
        [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:jsCall waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        // ...
    }
}
```
Event `data` are a JavaScript object and can have different attributes depending on event
