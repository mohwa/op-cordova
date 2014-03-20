var exec = require('cordova/exec');
var OpenPeer = {
  version: 0.0,

  settings: {
    namespaceGrantServiceURL: 'http://jsouter-v1-beta-1-i.hcs.io/grant.html',
    identityFederateBaseURI: 'identity://identity-v1-beta-1-i.hcs.io/',
    outerFrameURL:
      'http://jsouter-v1-beta-1-i.hcs.io/identity.html?view=choose&federated=false',
    redirectAfterLoginCompleteURL:
      'http://jsouter-v1-beta-1-i.hcs.io/identity.html?reload=true',
    lockBoxServiceDomain: 'lockbox-v1-beta-1-i.hcs.io',
    identityProviderDomain: 'identity-v1-beta-1-i.hcs.io',
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
    outgoingTelnetServerPort: 'tcp-logger-v1-beta-1-i.hcs.io:8055',
    archiveOutgoingTelnetLoggerServer: 'tcp-logger-v1-beta-1-i.hcs.io:8055',
    archiveTelnetLoggerServer: '59999',
    isOutgoingTelnetColorized: 'YES'
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

  stopCatPictures: function(interval) {
    exec(null, null, 'CDVOP', 'stopCatPictures');
  },

  configureApp: function(config) {
    var deferred = Q.defer();
    // TODO: copy values over onto settings
    return deferred.promise;
  },

  //TODO move to media object
  // 0:index, 1:top, 2:left, 3:width, 4:height, 5:zindex,
  // 6:contentMode, 7:scale, 8:opacity, 9:cornerRadius, 10:angle
  configureVideo: function(config) {
    exec(function() {
      console.log('successfully updated self video configuration');
    }, function(error) {
      console.log(error);
      }, 'CDVOP', 'configureVideo',
      [config.index, config.left, config.top, config.width, config.height,
       config.zindex, config.contentMode, config.scale, config.opacity,
       config.cornerRadius, config.angle]);
  },

  // user constructor
  user: function() {

    this.login = function(options) {
      var deferred = Q.defer();
      if (!options) var options = {};
      exec(function(identityId) {
        deferred.resolve(identityId);
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

