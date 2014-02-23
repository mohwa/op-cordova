cordova.define("org.openpeer.cordova.OP", function(require, exports, module) {
var exec = require('cordova/exec');
var OpenPeer = {
  version: 0.0,

  settings: {
    namespaceGrantServiceURL: 'http://jsouter-v1-beta-1-i.hcs.io/grant.html',
    identityFederateBaseURI: 'identity://identity-v1-beta-1-i.hcs.io/',
    outerFrameURL:
      'http://jsouter-v1-beta-1-i.hcs.io/identity.html?view=choose&federated=false',
    redirectURL: '',
    lockBoxServiceDomain: 'lockbox-v1-beta-1-i.hcs.io',
    identityProviderDomain: 'identity-v1-beta-1-i.hcs.io',

    // Logger settings
    isLoggerEnabled: 'NO',
    telnetPortForLogger: '59999',
    isLoggerColorized: 'YES',
    outgoingTelnetServerPort: 'tcp-logger-v1-beta-1-i.hcs.io:8055',
    isOutgoingTelnetColorized: 'YES'
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

  configureApp: function(config) {
    var deferred = Q.defer();

    return deferred.promise;
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
      }, 'CDVOP', 'startLoginProcess', [network]);
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

module.exports = OpenPeer;

});
