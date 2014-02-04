define(function() {
  //var exec = require('cordova/exec');
  return {
    version: 0.0,
    getAccountStatus: function(success, error, options) {
      Cordova.exec(success, error, "OP", "getAccountState", []);
    }
  }
});

