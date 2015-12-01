angular
  .module('CloneDetection', ['ui.codemirror', 'CloneDetection.states', 'CloneDetection.Directives'])
  .controller('MainCtrl', function($scope) {

  })
  .run(function() {
    console.log("Angular: Clone Detection has started");
  });
