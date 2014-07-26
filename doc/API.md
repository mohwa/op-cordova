# Open Peer Cordova Plugin JavaScript API
This document describes the JavaScript API which you can use to interact with the
Open Peer Cordova Plugin.

## OP Instance
An instance of the open peer API is created for your Cordova application and
is available via the global name `OP`.

## Update Settings
Before initializing the SDK, you have a chance to change any of the default settings, for example:

```
OP.updateSettings({
  isLoggerEnabled: false,
  telnetPortForLogger: '59999',
  outerFrameURL: 'http://you.outer.frame',
  identityProviderDomain: 'your.identity.provider'
})
```
There are many more options available. To see a full list of options available
checkout the [op.js](https://github.com/openpeer/op-cordova/blob/master/www/op.js)
default settings object.

## Initialize
This will initialize the native SDK
```
OP.initialize();
```

## Authorize
In order to securely connect to an open peer network you must obtain an
*application id* and a *shared secret*. In production it is important that you
obtain this data via an API call dynamically as opposed to storing it in your app.
During development however you may hardcode these values that you obtain
when you register your app on [fly.hookflash.me](http://fly.hookflash.me), for example
```
OP.authorizeApp({
  id: 'com.your.app.id',
  sharedSecret: 'e47d55b313a4646346...'
}).then(function(authorizedId) {
  // the application has been authorized to securely access the open peer network
});
```

## User
Create a user object that represents the locally logged in user:
```
var user = new OP.user();
```
Optionally, for more advance integration, you can modify the user prototype
to add custom properties before creating the user object.
For example here is an example adding a custom property to user object to keep
track of the contact they have selected:
```
OP.user.prototype.selectedContactId = -1;
OP.user.prototype.getSelectedContact = function() {
  if (this.selectedContactId != -1) {
    return this.contacts[this.selectedContactId];
  } else {
    return null;
  }
};
var user = new OP.user();
```

## Login
Open peer SDK handles login behind the scene for you and this plugin will
display the dedicated login web views when authentication is required.
You just need to initiate the login process when you application starts.
```
user.login();
```
That is enough to initiate the login process. You can optionally specify padding
around the login view. Default padding is `0` which means fullscreen.
Login returns a promise, so you can handle the success and error cases.
```
user.login({
    paddingTop: 60,
    paddingLeft: 10,
    paddingRight: 10,
    paddingBottom: 20
  }).then(function(identity) {
  console.log('login finished successfully ' + identity.uri);
}, function(error) {
  console.log('login canceled: ' + error);
});

```
### Logout
Start the logout process. Just like the login, this process uses the native
web views to logout from each identity.
```
user.logout().then(function() {
  console.log('logout from all identities')
}, function(error) {
  console.log(error);
});
```
> Currently logout from *all* identities is supported only

## Contacts
You load contacts by calling the `loadContacts()` method on the `user` object.
This will give you a promise object and will deliver the contact list to you once
it is downloaded. Here is a full example, assuming you have a *DIV* element
called `contactsList`, to load and display a list of contacts
```
user.loadContacts().then(function() {
    contactsList.innerHTML = '';
    for (var id in app.user.contacts) {
      var li = document.createElement('li');
      var img = document.createElement('img');
      img.src = app.user.contacts[id].avatarUrl;
      li.innerText = app.user.contacts[id].name;
      li.setAttribute('data-id', id);
      if (app.user.contacts[id].isRegistered == 'YES') {
        li.classList.add('op-user');
      }
      li.appendChild(img);
      contactsList.appendChild(li);
    }
  }, function(error) {
    console.log(error);
  });
});

Contacts are currently identified using `identityURI`.
```
## Call
To place a call to a peer who is on open peer network, all you need is their 'id'
```
OP.placeCall({peerList: [contactId]});
```
> this is so in future when we support group calls, you would use the same syntax

Handling call events and performing call related action is done using a `CallManager` object.
```
// create a call manager for current local user
app.callManager = new OP.CallManager(app.user);
```

### Call State Changes
There are number of state changes that can happen during life cycle of a call.
You may want to listen to some of these events and update your application UI accordingly

```
// Listen to any of the call events: 'call-preparing', 'call-incoming',
// 'call-ringing', 'call-ringback' 'call-open', 'call-onhold',
// 'call-closing', 'call-closed'
app.callManager.on('call-preparing', function(call) {
  app.callStateSpan.innerHTML = 'Preparing call ... ';
});
app.callManager.on('call-incoming', function(call) {
  app.callStateSpan.innerHTML = 'Incoming call from ' +
    call.peer.name + ' ... ';
});
app.callManager.on('call-ringing', function(call) {
  app.callStateSpan.innerHTML = 'Ringing ... ';
  app.incomingSound.loop = true;
  app.incomingSound.play();
  app.answerCallBtn.classList.remove('hide');
  app.hangupCallBtn.classList.remove('hide');
});
app.callManager.on('call-ringback', function(call) {
  app.callStateSpan.innerHTML = 'Calling ' + call.peer.name + ' ... ';
  app.ringbackSound.loop = true;
  app.ringbackSound.play();
  app.answerCallBtn.classList.add('hide');
  app.hangupCallBtn.classList.remove('hide');
});
app.callManager.on('call-open', function(call) {
  app.callStateSpan.innerHTML = 'Talking with ' + call.peer.name;
  app.answerCallBtn.classList.add('hide');
  app.hangupCallBtn.classList.remove('hide');
  app.incomingSound.pause();
  app.ringbackSound.pause();
  app.setupVideoViews();
});
app.callManager.on('call-onhold', function(call) {
  app.callStateSpan.innerHTML = 'Call with ' + call.peer.name + ' on Hold';
});
app.callManager.on('call-closing', function(call) {
  console.log('Closing call with ' + call.peer.name);
});
app.callManager.on('call-closed', function(call) {
  // call closed
});
```

## Messaging
You can send a message to any contact by calling `sendMessage` on the contact object.
For example, lets assume you have the `id` of the contact who you want to send a message to:
```
// first get the contact object
var contact = user.contacts[id];
var msg = 'Pretty nice eh?!';

// optionally, check that the contact is registered on open peer network
if (app.user.contacts[id].isRegistered) {
  app.user.contacts[id].sendMessage(msg);
}
```
> note that if contact is not registered, the message can not be delivered

Since all messages are arriving for the locally logged in user, to receive a message you
would listen to the `message-received` event on the `user` object that you created above.
Of course user must be logged in before he or she can receive any messages.
```
user.on('message-received', function(msg) {
  // msg.sender is the contact object who sent the message
  alert(msg.sender.name + ' says ' + msg.text + ' @' + msg.date);
});
```

## Video
That is why you are here after all, you want to see the video of yourself
and your peer (or your cat) in your app. Actually, ou dont have to do anything.
The plugin will display the videos as soon as a call is open. However,
you probably want to change the position, size or other attributes of the videos.
In order to do that, create an instance of `Video` object passing it the
index of the video you would like to control. Index `0` is video of yourself and
index `1` or higher is used for peer videos.

> note currently only two way video chat is supported

Here is an example:

```
var selfVid = new OP.Video(0);
var peerVid = new OP.Video(1);
```
Lets move the video of ourself to bottom and set corner radius for more smooth look
Note that you can use % for left, top, width and height. Otherwise the number
will be interpreted as pixels.
```
selfVid.width = '10%';
selfVid.height = '10%';
selfVid.top = '70%';
selfVid.left = 50%;
selfVid.cornerRadius = 20;
selfVid.opacity = 0.7;
```
Make the peer video full screen.
```
peerVid.left = 0;
peerVid.top = 0;
peerVid.width = '100%';
peerVid.height = '100%';
```
Since the video views are being rendered using native elements, the plugin
provides many attributes to let you modify them to your needs. If there is
anything you would like to see that is not possible,
please [open an issue](https://github.com/openpeer/op-cordova/issues?state=open).

## Shutdown
When you are about to close the app, you can shutdown the SDK. This will fire a
`shutdown` event on the open peer object, which can optionally be used to verify
that shutdown was successful
```
OP.shutdown();
```
