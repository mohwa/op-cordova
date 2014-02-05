define(['op'], function(op) {

  var authorizeAppBtn = document.getElementById('authorize-app-btn');
  var authorizedAppIdEl = document.getElementById('authorized-app-id');

  op.appId = "com.arasbm.opdemo";
  op.appSharedSecret = "6f4007dfc560abf2691527dc41941264cb9f2b05";

  authorizeAppBtn.addEventListener('click', function() {
    op.authorizeApp(function(id) {
      authorizedAppIdEl.innerHTML = 'Authorized app id is: ' + id;
    },
    function(err) {
      alert('error: ' + err);
    });
  });

});
