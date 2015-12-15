angular.module('CloneDetection').controller('DonutCtrl', function ($scope, DonutService) {

  var stop = $scope.$watch('cloneData', function (cloneData) {
    if (cloneData) {
      stop();
      DonutService.render(cloneData, function (name) {
        $scope.$apply(function () {
          $scope.activeClones = cloneData.clones.filter(function (cloneClass) {
            return _.some(cloneClass.fragments, function (fragment) {
              return fragment.file == name;
            });
          });
        });
      });
    }
  })
});