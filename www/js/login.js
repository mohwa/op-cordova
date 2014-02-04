define(['op'], function(op) {
  //TODO: check to see if user is already logged in

  var user = document.getElementById('username');
  var pass = document.getElementById('password');
  var loginBtn = document.getElementById('login-btn');
  var accountStatusBtn = document.getElementById('account-status-btn');

  loginBtn.addEventListener('click', function() {
    console.log('attempting to login for ' + user.value);
  });

  accountStatusBtn.addEventListener('click', function() {
    console.log('asked for account status');
    op.getAccountStatus(function(s) {
      alert('got account status: ' + s);
    },
    function() {
      alert('could not get account status');
    });
  });

});
