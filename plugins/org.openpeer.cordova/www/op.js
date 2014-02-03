
var opExport = {};

opExport.getAccountStatus = function(success, error, options) {
  exec(success, error, "CDVOP", "getAccountState", []);
};

module.exports = opExport;

