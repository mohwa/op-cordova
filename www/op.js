var exec = require('cordova/exec');
module.exports = {
  version: 0.0,
  getAccountStatus: function(success, error, options) {
    Cordova.exec(success, error, 'OP', 'getAccountState', []);
  },

  authorizeApp: function(app) {
    var deferred = Q.deffered();

    exec(function(authorizedKey) {
      deferred.resolve(authorizedKey);
    }, function(error) {
      deferred.reject(new Error('could not authorize app: ' + error));
    }, 'OP', 'authorizeApp', [app.id, app.sharedSecret]);

    return deferred.promise;
  },

  configureApp: function(config) {
    var deferred = Q.deffered();

    return deferred.promise;
  }

}


