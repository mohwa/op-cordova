define(function() {
  //var exec = require('cordova/exec');
  return {
    version: 0.0,
    appId: null,
    appSharedSecret: null,
    authorizedAppId: null,
    getAccountStatus: function(success, error, options) {
      Cordova.exec(success, error, "OP", "getAccountState", []);
    },
    authorizeApp: function(success, error) {
      if (this.authorizedAppId) {
        error("App has already been authorized")
      } else if (!this.appId || !this.appSharedSecret) {
        error("Please first set op.appId and op.appSharedSecret");
      } else {
        Cordova.exec(success, error, "OP", "authorizeApp", [this.appId, this.appSharedSecret]);
      }
    },

  }
});

