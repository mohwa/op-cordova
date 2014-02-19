
var exec = require('cordova/exec');
module.exports = {
  version: 0.0,
  getAccountStatus: function(success, error, options) {
    exec(success, error, 'CDVOP', 'getAccountState', []);
  },

  authorizeApp: function(app) {
    var deferred = Q.defer();

    exec(function(authorizedKey) {
      deferred.resolve(authorizedKey);
    }, function(error) {
      deferred.reject(new Error('could not authorize app: ' + error));
    }, 'CDVOP', 'authorizeApp', [app.id, app.sharedSecret]);

    return deferred.promise;
  },

  showCatPictures: function(interval) {
    exec(null, null, 'CDVOP', 'showCatPictures', [interval]);
  },

  configureApp: function(config) {
    var deferred = Q.defer();

    return deferred.promise;
  }

}

