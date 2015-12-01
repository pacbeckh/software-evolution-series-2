angular
  .module('CloneDetection', ['ui.codemirror', 'ui.bootstrap', 'treeControl', 'CloneDetection.states'])
  .controller('MainCtrl', function($scope, $state) {
    $scope.$state = $state;
  })
  .run(function() {
    console.log("Angular: Clone Detection has started");
  });
