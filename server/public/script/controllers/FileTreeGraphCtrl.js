angular.module('CloneDetection').controller('FileTreeGraphCtrl', function ($scope, $state, FileTreeService) {

  var stop = $scope.$watch('cloneData', function (cloneData) {
    if (cloneData) {
      stop();

      FileTreeService.render(angular.copy(cloneData.files), function(d) {
        $scope.$apply(function() {
          $state.go('app.files', {path: d.path});
        })
      });
    }
  })
});