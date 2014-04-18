var exec = require('cordova/exec');
var OpenPeer = {
  version: 0.0,

  settings: {
    outerFrameURL:
      'http://jsouter-v1-rel-lespaul-i.hcs.io/identity.html?view=choose',
    identityProviderDomain: 'identity-v1-rel-lespaul-i.hcs.io',
    identityFederateBaseURI: 'identity://identity-v1-rel-lespaul-i.hcs.io/',
    namespaceGrantServiceURL:
      'http://jsouter-v1-rel-lespaul-i.hcs.io/grant.html',
    lockBoxServiceDomain: 'lockbox-v1-rel-lespaul-i.hcs.io',
    defaultOutgoingTelnetServer: 'tcp-logger-v1-rel-lespaul-i.hcs.io:8055',
    applicationSettingsVersion: '1',

//TODO: investigate why enabling (some of?) these causes performance issue
/*
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
    'openpeer/services/debug/only-allow-data-sent-to-specific-ips': '',
    'openpeer/services/debug/only-allow-turn-to-relay-data-sent-to-specific-ips': '',
*/

    redirectAfterLoginCompleteURL:
      'http://jsouter-v1-rel-lespaul-i.hcs.io/identity.html?reload=true',
    'openpeer/stack/bootstrapper-force-well-known-over-insecure-http': true,
    'openpeer/stack/bootstrapper-force-well-known-using-post': true,

    // Application brand settings
    'openpeer/common/application-name': 'appname2',
    'openpeer/common/application-url': 'appurl2',
    'openpeer/common/application-image-url': 'appimgurl2',

    // calculated settings (these will be set by the SDK)
    'openpeer/calculated/authorizated-application-id': '',
    'openpeer/calculated/user-agent': '',
    'openpeer/calculated/device-id': '',
    'openpeer/calculated/os': '',

    // Media Settings
    isMediaAECOn: true,
    isMediaAGCOn: true,
    isMediaNSOn: true,

    // Logger settings
    isLoggerEnabled: true,
    telnetPortForLogger: '59999',
    isLoggerColorized: true,
    outgoingTelnetServerPort: 'tcp-logger-v1-rel-lespaul-i.hcs.io:8055',
    archiveOutgoingTelnetLoggerServer: 'tcp-logger-v1-beta-1-i.hcs.io:8055',
    archiveTelnetLoggerServer: '59999',
    'localTelnetLoggerPort': 59999,
    isOutgoingTelnetColorized: true
  },

  initialize: function() {
     exec(function() {
        console.log('OP is initialized and ready');
      }, function(error) {
        //TODO: error
      }, 'CDVOP', 'initialize', []);
  },

  getAccountStatus: function(success, error, options) {
    exec(success, error, 'CDVOP', 'getAccountState', []);
  },

  authorizeApp: function(app) {
    var deferred = Q.defer();
    if (app.id && app.sharedSecret) {
      exec(function(authorizedKey) {
        deferred.resolve(authorizedKey);
      }, function(error) {
        deferred.reject(new Error('could not authorize app: ' + error));
      }, 'CDVOP', 'authorizeApp', [app.id, app.sharedSecret]);
    } else {
      deferred.reject(new Error(
        'Please provide an object with id and sharedSecret attributes'));
    }
    return deferred.promise;
  },

  showCatPictures: function(interval) {
    exec(null, null, 'CDVOP', 'showCatPictures', [interval]);
  },

  stopCatPictures: function() {
    exec(null, null, 'CDVOP', 'stopCatPictures', []);
  },

  configureApp: function(config) {
    var deferred = Q.defer();
    // TODO: copy values over onto settings
    return deferred.promise;
  },

  // user constructor
  user: function() {
    this.name = '';
    this.avatarUrl = '';
    this.contacts = {test: 'empty'};

    this.login = function(options) {
      var deferred = Q.defer();
      if (!options) var options = {};
      exec(function(identity) {

        deferred.resolve(identity);
      }, function(error) {
        deferred.reject(new Error('login failed: ' + error));
      }, 'CDVOP', 'startLoginProcess', [
        options.identityFederateBaseURI ||
          OpenPeer.settings.identityFederateBaseURI,
        options.outerFrameURL || OpenPeer.settings.outerFrameURL,
        options.redirectURL || OpenPeer.settings.redirectURL,
        options.identityProviderDomain ||
          OpenPeer.settings.identityProviderDomain
      ]);
      return deferred.promise;
    };

    // network: social network to logout from
    // if no parameter specified will logout from all networks
    this.logout = function(network) {
      var deferred = Q.defer();
      exec(function() {
        deferred.resolve();
      }, function(error) {
        deferred.reject(new Error('logout failed: ' + error));
      }, 'CDVOP', 'logout', [network]);
      return deferred.promise;
    };

    // ask SDK to give us the list of contacts for current user
    // when finished the list will be loaded into `user.contacts`
    this.loadContacts = function(options) {
      var deferred = Q.defer();
      var user = this;
      if (!options) options = {};

      exec(function(contactsList) {
        user.contacts = contactsList;
        deferred.resolve();
      }, function(error) {
        deferred.reject(new Error('failed to obtain list of contacts: ' +
          error));
      }, 'CDVOP', 'getListOfContacts', [
        options.avatarWidth || 64,
        options.onlyOPContacts || false, // only get users registered in OP
        options.hardRefresh || false]); // tell server to pull latest contacts
      return deferred.promise;
    };
  },

  media: {
    switchCamera: function(success, error, camera) {
      exec(success, error, 'CDVOP', 'switchCamera', [camera]);
    },
    //video controller constructor
    Video: function(index, config) {
      if (!config) config = {};
      var index = index;
      this.__defineGetter__('index', function() { return index; });

      var left = config.left || 0;
      this.__defineGetter__('left', function() { return left; });
      this.__defineSetter__('left', function(val) {
        left = val;
        _applyChanges(this);
      });

      var top = config.top || (200 * index);
      this.__defineGetter__('top', function() { return top; });
      this.__defineSetter__('top', function(val) {
        top = val;
        _applyChanges(this);
      });

      var width = config.width || 300;
      this.__defineGetter__('width', function() { return width; });
      this.__defineSetter__('width', function(val) {
        width = val;
        _applyChanges(this);
      });

      var height = config.height || 200;
      this.__defineGetter__('height', function() { return height; });
      this.__defineSetter__('height', function(val) {
        height = val;
        _applyChanges(this);
      });

      var zindex = config.zindex || (100 - 10 * index);
      this.__defineGetter__('zindex', function() { return zindex; });
      this.__defineSetter__('zindex', function(val) {
        zindex = val;
        _applyChanges(this);
      });

      var contentMode = config.contentMode || 'scaleAspectFill';
      this.__defineGetter__('contentMode', function() { return contentMode; });
      this.__defineSetter__('contentMode', function(val) {
        contentMode = val;
        _applyChanges(this);
      });

      var scale = config.scale || 1;
      this.__defineGetter__('scale', function() { return scale; });
      this.__defineSetter__('scale', function(val) {
        scale = val;
        _applyChanges(this);
      });

      var opacity = config.opacity || 1;
      this.__defineGetter__('opacity', function() { return opacity; });
      this.__defineSetter__('opacity', function(val) {
        opacity = val;
        _applyChanges(this);
      });

      var cornerRadius = config.cornerRadius || 20;
      this.__defineGetter__('cornerRadius', function() { return cornerRadius;});
      this.__defineSetter__('cornerRadius', function(val) {
        cornerRadius = val;
        _applyChanges(this);
      });

      var angle = config.angle || 0;
      this.__defineGetter__('angle', function() { return angle; });
      this.__defineSetter__('angle', function(val) {
        angle = val;
        _applyChanges(this);
      });

      function _applyChanges(video) {
        exec(function() {
          console.log('successfully updated self video configuration');
        }, function(error) {
          console.log(error);
          }, 'CDVOP', 'configureVideo',
          [video.index, video.left, video.top, video.width, video.height,
           video.zindex, video.contentMode, video.scale, video.opacity,
           video.cornerRadius, video.angle]);
      };
      _applyChanges(this);
    }
  },

  // call constructor
  call: function(options) {

    this.start = function() {
      console.log('starting call [TODO]');
    };

    // toggle mute of set explicitely to muteOn
    this.mute = function(muteOn) {
      console.log('setting mute [TODO] ' + muteOn);
    };
  }
};

OpenPeer.initialize();
module.exports = OpenPeer;


