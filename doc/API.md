# op-cordova JavaScript API
This document desctibes the JavaScript API you can use to interact with this Open Peer Cordova Plugin. 

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
There are many more options available. To see a full list of options available checkout the (op.js)[https://github.com/openpeer/op-cordova/blob/master/www/op.js] default settings object.

## Initialize
This will initialize the native SDK
```
OP.initialize();
```

## Authorize
```
OP.authorizeApp({
  id: 'com.your.app.id',
  sharedSecret: 'e47d55b313a4646346...'
}).then(function(authorizedId) {
  // the application has been authorized to access the open peer network
});
```

## User
Create a user object that represents the logged in user:
```
var user = new OP.user();
```
Optionally, for more advance integration, you can modify the user prototype to add custom properies before creating the user object. For example here is an example adding a custom propery to user object to keep track of the contact they have selected:
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

## Contacts
You load contacts by calling the `loadContacts()` method on the `user` object. This will give you a promise object and will deliver the contact list to you once it is downloaded. Here is a full example:
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
```
