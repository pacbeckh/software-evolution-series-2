angular.module('CloneDetection').controller('ProblemsCtrl', function ($scope) {
  var self = this;

  var stop = $scope.$watch('cloneData', function(cloneData) {
    if (cloneData) {
      stop();

      self.problemFiles = cloneData.problemFiles.concat([]);
      self.problemFiles.sort(function(a, b) {
        return b.percentageDuplicated - a.percentageDuplicated;
      });
    }
  })
});