define(['login', 'setting'], function(login, setting) {

  if (document.readyState == 'complete') {
    init();
  } else {
    document.addEventListener('DOMContentLoaded', init);
  }     

  function init() {
    console.log('initializing');
  }
});
