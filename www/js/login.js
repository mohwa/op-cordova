define(function() {
  //TODO: check to see if user is already logged in

  var user = document.getElementById('username');
  var pass = document.getElementById('password');
  var loginBtn = document.getElementById('login-btn');

  loginBtn.addEventListener('click', function() {
    console.log('attempting to login for ' + user.value);
  });

});
