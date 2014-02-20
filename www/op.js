var exec = require('cordova/exec');
module.exports = {
  version: 0.0,

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
    this.defaultOptions: {
      identityBaseURI: 'identity://idprovider-javascript.hookflash.me/',
      outerFrameURL:
        'https://app-javascript.hookflash.me/outer.html?view=choose',
      redirectURL: 'https://app-javascript.hookflash.me/outer.html?reload=true',
      identityProviderDomain: 'idprovider-javascript.hookflash.me'
    };

    this.login = function(options) {
      var deferred = Q.defer();
      exec(function(identityId) {
        deferred.resolve(identityId);
      }, function(error) {
        deferred.reject(new Error('login failed: ' + error));
      }, 'CDVOP', 'startLoginProcess', [
        options.identityBaseURI || defaultOptions.identityBaseURI,
        options.outerFrameURL || defaultOptions.outerFrameURL,
        options.redirectURL || defaultOptions.redirectURL,
        options.identityProviderDomain || defaultOptions.identityProviderDomain
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

