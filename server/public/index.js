angular
  .module('CloneDetection', ['ui.codemirror', 'ui.bootstrap', 'CloneDetection.states', 'CloneDetection.Directives'])
  .controller('MainCtrl', function($scope) {

  })
  .run(function() {
    console.log("Angular: Clone Detection has started");
  });
