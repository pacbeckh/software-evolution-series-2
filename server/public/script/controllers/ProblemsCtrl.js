angular.module('CloneDetection').controller('ProblemsCtrl', function ($scope) {
  var self = this;

  var stop = $scope.$watch('cloneData', function(clones) {
    if (clones) {
      stop();

      self.problemFiles = clones.problemFiles.concat([]);

      self.problemFiles.sort(function(a, b) {
        return b.percentageDuplicated - a.percentageDuplicated;
      });
    }
  })
});