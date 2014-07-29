
/**
 * This component wraps all native OP calls in an API that is
 * when packaging the plugin for production
 */

  const CORDOVA = cordova;
  var EventEmitter2 = EventEmitter2 || EE2.EventEmitter2;
  var openPeerInstance = null;
  function addInstance(openpeer) {
    if (openPeerInstance) {
      throw new Error("An OpenPeer instance already exists! Make sure you call destroy on the existing one before creating a new one!");
    }
    openPeerInstance = openpeer;
  }
  function removeInstance(openpeer) {
    openPeerInstance = null;
  }

  // returns Q deferred object that can be resolved/rejected
  function callNative(method, args) {
    var deferred = Q.defer();
    args = args || [];

    CORDOVA.exec(function(data) {
      deferred.resolve(data);
    }, function(err) {
      deferred.reject(err);
    }, 'CDVOP', method, args);
    return deferred;
  }

  // this method is called directly from native to fire events
  // see https://github.com/openpeer/op-cordova/blob/master/doc/Events.md
  window.__CDVOP_MESSAGE_HANDLER = function(type, args) {
    if (!openPeerInstance) {
      console.error("Not passing along message '" + type + "' because there is no OpenPeer instance.");
    }
    openPeerInstance.emit("CDVOP_MESSAGE", type, args);
  }

  // need reference to instance for native to access settings
  window.__CDVOP_GET_INSTANCE = function() {
    return openPeerInstance;
  }

  const VERSION = '0.1.0';
  const SETTINGS = {
    outerFrameURL:
      'http://jsouter-v1-rel-lespaul-i.hcs.io/identity.html?view=choose',
    identityProviderDomain: 'identity-v1-rel-lespaul-i.hcs.io',
    identityFederateBaseURI: 'identity://identity-v1-rel-lespaul-i.hcs.io/',
    namespaceGrantServiceURL:
      'http://jsouter-v1-rel-lespaul-i.hcs.io/grant.html',
    lockBoxServiceDomain: 'lockbox-v1-rel-lespaul-i.hcs.io',
    applicationSettingsVersion: '1',

    'applicationSettingsBackgroundingPhaseRichPush': 4,
    'openpeer/core/core-thread-priority': 'normal',
    'openpeer/core/media-thread-priority': 'real-time',
    'openpeer/core/backgrounding-phase-conversation-thread': 1,
    'openpeer/core/backgrounding-phase-account': 1,
    'openpeer/core/auto-find-peers-added-to-conversation-in-seconds': 600,
    'openpeer/stack/stack-thread-priority': 'normal',
    'openpeer/stack/key-generation-thread-priority': 'low',
    'openpeer/stack/backgrounding-phase-account': 2,
    'openpeer/stack/bootstrapper-force-well-known-over-insecure-http': true,
    'openpeer/stack/bootstrapper-force-well-known-using-post': true,
    'openpeer/stack/finder-max-client-session-keep-alive-in-seconds': 300,
    'openpeer/stack/finder-connection-send-ping-keep-alive-after-in-seconds': 0,
    'openpeer/stack/move-publication-to-cache-time-in-seconds': 120,
    'openpeer/stack/debug/force-p2p-messages-over-finder-relay': false,
    'openpeer/services/services-thread-priority': 'high',
    'openpeer/services/logger-thread-priority': 'normal',
    'openpeer/services/socket-monitor-thread-priority': 'real-time',
    'openpeer/services/timer-monitor-thread-priority': 'normal',
    'openpeer/services/http-thread-priority': 'normal',
    'openpeer/services/backgrounding-phase-ice-socket-session': 3,
    'openpeer/services/backgrounding-phase-turn': 3,
    'openpeer/services/backgrounding-phase-tcp-messaging': 3,
    'openpeer/services/backgrounding-phase-telnet-logger': 5,
    'openpeer/services/backgrounding-phase-1-timeout-in-seconds': 8,
    'openpeer/services/backgrounding-phase-2-timeout-in-seconds': 0,
    'openpeer/services/backgrounding-phase-3-timeout-in-seconds': 0,
    'openpeer/services/backgrounding-phase-4-timeout-in-seconds': 0,
    'openpeer/services/backgrounding-phase-5-timeout-in-seconds': 0,
    'openpeer/services/process-application-message-queue-on-quit': true,
    'openpeer/services/turn-candidates-must-remain-alive-after-ice-wake-up-in-seconds': 600,
    'openpeer/services/interface-name-order': 'lo;en;pdp_ip;stf;gif;bbptp;p2p',
    'openpeer/services/support-ipv6': false,
    'openpeer/services/debug/force-packets-over-turn': false,
    'openpeer/services/debug/force-turn-to-use-tcp': false,
    'openpeer/services/debug/force-turn-to-use-udp': false,

    redirectAfterLoginCompleteURL:
      'http://jsouter-v1-rel-lespaul-i.hcs.io/identity.html?reload=true',
    'openpeer/stack/bootstrapper-force-well-known-over-insecure-http': true,
    'openpeer/stack/bootstrapper-force-well-known-using-post': true,

    // Application brand settings
    'openpeer/common/application-name': 'appname2',
    'openpeer/common/application-url': 'appurl2',
    'openpeer/common/application-image-url': 'appimgurl2',

    // Media Settings
    isMediaAECOn: true,
    isMediaAGCOn: true,
    isMediaNSOn: true,

    /*** Logger settings ***/

    // if this is set to false there will be *no logging* regardless
    // change this to true before application initialization to enable logger
    isLoggerEnabled: true,

    // the log levels are set in the native bridge layer
    // choose from: [none, basic, detail, debug, trace, insane]
    logLevelForApplication: 'trace',
    logLevelForServices: 'trace',
    logLevelForServicesWire: 'debug',
    logLevelForServicesIce: 'trace',
    logLevelForServicesTurn: 'trace',
    logLevelForServicesRudp: 'debug',
    logLevelForServicesHttp: 'insane', // TODO: switch back to 'debug',
    logLevelForServicesMls: 'trace',
    logLevelForServicesTcp: 'trace',
    logLevelForServicesTransport: 'debug',
    logLevelForCore: 'trace',
    logLevelForStackMessage: 'trace',
    logLevelForStack: 'trace',
    logLevelForWebRTC: 'detail',
    logLevelForZsLib: 'trace',
    logLevelForSDK: 'trace',
    logLevelForZsLibSocket: 'debug',
    logLevelForSDK: 'trace',
    logLevelForMedia: 'detail',
    logLevelForJavaScript: 'trace',

    isLoggerColorized: true,
    isOutgoingTelnetLoggerEnabled: true,
    isTelnetLoggerEnabled: false,
    isStandardLoggerEnabled: true,
    telnetPortForLogger: '59999',
    defaultOutgoingTelnetServer: 'tcp-logger-v1-rel-lespaul-i.hcs.io:8055',
    archiveOutgoingTelnetLoggerServer: 'tcp-logger-v1-beta-1-i.hcs.io:8055',
    archiveTelnetLoggerServer: '59999',
    'localTelnetLoggerPort': 59999,
    isOutgoingTelnetColorized: true,

    /*** calculated settings (these will be set by the SDK) ***/
    /*** Do *NOT* set these manually ***/
    'openpeer/calculated/authorizated-application-id': '',
    'openpeer/calculated/user-agent': '',
    'openpeer/calculated/device-id': '',
    'openpeer/calculated/os': ''
  };

  // chat session constructor
  var Chat = function(config) {
    var self = this;

    // TODO: figure out a way to get the conversationId/sessionId
    self.chatId = 'idisnotset';

    self._config = config;

    // list of messages in this chat
    // TODO: when history is supported, load this from SDK
    self.conversation = {};

    if (!self._config.peerList || self._config.peerList.length < 1) {
      throw 'InvalidChatPeerList';
    } else {
      // TODO: see if this is necessary
      // to connect message recived callback for this chat session
    }
  };

  Chat.prototype.sendMessage = function(msg) {
    var self = this;
    var options = [msg].concat(self._config.peerList);
    if (!msg) {
      throw new Error('please provide a message to send');
    } else {
      return callNative('sendMessageToPeer', options).promise;
    }
  };

  // represents a contact otherwise knows as a peer
  var Contact = function(user, contactInfo) {
    var self = this;
    self.openpeer = __CDVOP_GET_INSTANCE();
    self._call = null;
    self.localUser = user;
    self._chat = null;

    // add all contact info to this object
    for (var name in contactInfo) {
      // fix boolean values that come as string from iOS
      if(name == 'isRegistered') {
        self['isRegistered'] = contactInfo['isRegistered'] == 'true';
      } else {
        self[name] = contactInfo[name];
      }
    }
  }
  Contact.prototype.sendMessage = function (msg) {
    self = this;
    if(!self._chat) {
      // create a chat object for each contacts to send and recieve messages
      self._chat = new Chat({peerList:[self.identityURI]});
    }
    return self._chat.sendMessage(msg)
  }
  Contact.prototype.startCall = function () {
    self = this;
    self._call = new Call(self.localUser, contact);
    return self._call;
  }
  Contact.prototype._receiveCall = function (call) {
    self = this;
    //TODO
    self._call = call;
  }

  var Call = function(user, callInfo) {
    var self = this;
    self.localUser = user;
    self.openpeer = __CDVOP_GET_INSTANCE();

    // TODO: change this when we support group calls
    self.peer = user.contacts[callInfo.identityURI];
    self.sessionId = 'unknown';

    // add other call info to this object
    for (var name in callInfo) {
        self[name] = callInfo[name];
    };

    self.answer = function() {
      return self.openpeer._callNative('answerCall', [self.sessionId]).promise;
    };

    self.hangup = function() {
      return self.openpeer._callNative('hangupCall', [self.sessionId]).promise;
    };
  }

  // Object for controlling calls between local user and any of their contacts
  var CallManager = function(user) {
    var self = this;
    self.user = user;
    self.openpeer = __CDVOP_GET_INSTANCE();

    self.openpeer.on("CDVOP_MESSAGE", function(type, args) {
      if (type === 'callStateChange') {

        self.currentCall = new Call(self.user, args);

        console.log('OP received call state change event to: >> ' + args.callState);
        /*
         * one of these callState events will be fired:
         * ['call-preparing', 'call-incoming', 'call-ringing', 'call-ringback'
         *  'call-open', 'call-onhold', 'call-closing', 'call-closed']
         */
        self.emit(args.callState, self.currentCall);
      }
    });

    // camera can be either 'front' or 'back'. Will toggle if no/wrong argument
    self.toggleCamera = function(camera) {
      return self.openpeer._callNative('switchCamera', [camera]).promise;
    };

    // toggle mute for local mic
    self.toggleMute = function() {
      return self.openpeer._callNative('toggleMute').promise;
    };

    // toggle mute for local mic
    self.toggleSpeaker = function() {
      return self.openpeer._callNative('toggleSpeaker').promise;
    };
  }
  console.log('ee', EventEmitter2);
  CallManager.prototype = Object.create(EventEmitter2.prototype);

  // represents the current user
  var User = function() {
    var self = this;
    self.openpeer = __CDVOP_GET_INSTANCE();

    self.name = '';
    self.avatarUrl = '';

    // maps identityURI of peer to instances of Contact object
    self.contacts = {};

    self._login_deferred = null;
    self.login = function(options) {
      options = options || {};
      self._login_deferred = self.openpeer._callNative('startLoginProcess', [
        options.paddingTop || 0,
        options.paddingRight || 0,
        options.paddingBottom || 0,
        options.paddingLeft || 0
      ]);
      return self._login_deferred.promise;
    };

    // network: social network to logout from
    // if no parameter specified will logout from all networks
    self.logout = function(network) {
      // if login is in progress, cancel it
      network = network || 'all';
      if (Q.isPending(self._login_deferred.promise)) {
        self._login_deferred.reject('Login canceled due to logout');
      }
      return self.openpeer._callNative('logout', [network]).promise;
    };

    // ask SDK to give us the list of contacts for current user
    // when finished the list will be loaded into `user.contacts`
    // caller revieved a promise that will be fultilled when contacts are ready
    self.loadContacts = function(options) {
      options = options || {};
      var promise = self.openpeer._callNative('getListOfContacts', [
        options.avatarWidth || 64,
        // only get users registered in OP network
        options.onlyOPContacts || false,
        // tell server to pull latest contacts
        options.hardRefresh || false]).promise;

      promise.then(function(contactsMap) {
        for (var identityURI in contactsMap) {
          // attach identityURI itself to the contact object info
          contactsMap[identityURI].identityURI = identityURI;
          // create the self contained contact object that maps to the identityURI
          self.contacts[identityURI] = new Contact(self, contactsMap[identityURI]);
        }
      }, function(error) {
          // TODO: add error message
      });
      return promise;
    };

    self.openpeer.on('shutdown', function() {
      if (Q.isPending(self._login_deferred.promise)) {
        self._login_deferred.reject('Login canceled due to SDK shutdown');
      }
    });

    self.openpeer.on('CDVOP_MESSAGE', function(type, msg) {
      if (type === 'onMessageReceived') {
        msg.sender = self.contacts[msg.senderIdentityURI]
        self.emit('message-received', msg);
      }
    });
  }
  User.prototype.getContacts = function() {
    return this.contacts;
  }
  User.prototype.getContact = function(id) {
    return this.contacts[id];
  }
  // make user event emitter
  User.prototype = Object.create(EventEmitter2.prototype);

  // Video controller constructor
  var Video = function(index, config) {
    var self = this;
    self.openpeer = __CDVOP_GET_INSTANCE();

    if (!config) config = {};
    var index = index;
    self.__defineGetter__('index', function() { return index; });

    var left = config.left || 0;
    self.__defineGetter__('left', function() { return left; });
    self.__defineSetter__('left', function(val) {
      left = val;
      _applyChanges(this);
    });

    var top = config.top || (200 * index);
    self.__defineGetter__('top', function() { return top; });
    self.__defineSetter__('top', function(val) {
      top = val;
      _applyChanges(this);
    });

    var width = config.width || 300;
    self.__defineGetter__('width', function() { return width; });
    self.__defineSetter__('width', function(val) {
      width = val;
      _applyChanges(this);
    });

    var height = config.height || 200;
    self.__defineGetter__('height', function() { return height; });
    self.__defineSetter__('height', function(val) {
      height = val;
      _applyChanges(this);
    });

    var zindex = config.zindex || (100 - 10 * index);
    self.__defineGetter__('zindex', function() { return zindex; });
    self.__defineSetter__('zindex', function(val) {
      zindex = val;
      _applyChanges(this);
    });

    var contentMode = config.contentMode || 'scaleAspectFill';
    self.__defineGetter__('contentMode', function() { return contentMode; });
    self.__defineSetter__('contentMode', function(val) {
      contentMode = val;
      _applyChanges(this);
    });

    var scale = config.scale || 1;
    self.__defineGetter__('scale', function() { return scale; });
    self.__defineSetter__('scale', function(val) {
      scale = val;
      _applyChanges(this);
    });

    var opacity = config.opacity || 1;
    self.__defineGetter__('opacity', function() { return opacity; });
    self.__defineSetter__('opacity', function(val) {
      opacity = val;
      _applyChanges(this);
    });

    var cornerRadius = config.cornerRadius || 0;
    self.__defineGetter__('cornerRadius', function() { return cornerRadius;});
    self.__defineSetter__('cornerRadius', function(val) {
      cornerRadius = val;
      _applyChanges(this);
    });

    var angle = config.angle || 0;
    self.__defineGetter__('angle', function() { return angle; });
    self.__defineSetter__('angle', function(val) {
      angle = val;
      _applyChanges(this);
    });

    function _applyChanges(video) {
      // convert all values to string and send to SDK
      return self.openpeer._callNative('configureVideo',
        ['' + video.index, '' + video.left, '' + video.top, '' + video.width,
          '' + video.height, '' + video.zindex, '' + video.contentMode,
          '' + video.scale, '' + video.opacity, '' + video.cornerRadius,
          '' + video.angle]);
    };
  };


  var OpenPeer = function() {
    var self = this;
    addInstance(self);

    // apply default settings
    self._settings = SETTINGS;

    self.on('CDVOP_MESSAGE', function(type, args) {
      if (type === 'shutdown') {
        self.emit('shutdown', args);
      }
    });

    // change current settings. returs true only if there was any change
    self.changeSettings = function(config) {
      var changed = false;
      for (var name in config) {
        if (self._settings[name] != config[name]) {
          self._settings[name] = config[name];
          changed = true;
        }
      }
      return changed;
    };

    self.getAllSettings = function() {
      return self._settings;
    };

    self.getSettingForKey = function(key) {
      return self._settings[key];
    };

    self.initialize = function(settings) {
      settings = settings || {};

      // apply settings passed by client
      self.changeSettings(settings);

      return self._callNative('initialize').promise.fail(function (err) {
          err.message += ' (while initializing SDK)';
          err.stack += '\n(while initializing SDK)';
          throw err;
      });
    };

    // no need to call this unless you have changed the log levels in settings
    self.refreshLogger = function() {
      return self._callNative('refreshLogger').promise;
    };

    // 'shutdown' event is fired on OP after SDK shutdown
    self.shutdown = function() {
      return self._callNative('shutdown');
    };

    self.authorizeApp = function(app) {
      if (app.id && app.sharedSecret) {
        return self._callNative('authorizeApp', [app.id, app.sharedSecret])
        .promise.fail(function (err) {
          err.message += ' (while authorizing app)';
          err.stack += '\n(while authorizing app)';
          throw err;
        });
      } else {
        throw new Error(
          'Please provide an object with "id" and "sharedSecret" attributes');
      }
    };

    self.showCatPictures = function(interval) {
      exec(null, null, 'CDVOP', 'showCatPictures', [interval]);
    };

    self.stopCatPictures = function() {
      exec(null, null, 'CDVOP', 'stopCatPictures', []);
    };

    self.placeCall = function(config) {
      // TODO: figure out if we need conversation id or session id here
      var options = ['TODO:conversationID', !!config.showVideo].concat(config.peerList);

      return self._callNative('placeCall', options).promise.fail(function (err) {
        err.message += ' (while plaacing a call)';
        err.stack += '\n(while placing a call)';
        throw err;
      });
    };
  };

  // Extend OpenPeer with EE2
  OpenPeer.prototype = Object.create(EventEmitter2.prototype);

  OpenPeer.prototype.destroy = function() {
    // TODO: Do other work and then remove instance.
    removeInstance(this);
  }

  OpenPeer.prototype._callNative = callNative;

  OpenPeer.prototype.LocalUser = User;
  OpenPeer.prototype.Contact = Contact;
  OpenPeer.prototype.Video = Video;
  OpenPeer.prototype.CallManager = CallManager;

  if (module) {
    module.exports = new OpenPeer();
  } else {
    return new OpenPeer();
  }
