angular.module('CloneDetection').controller('MainCtrl', function ($scope, $state, $http, $timeout, Notification) {
  $scope.$state = $state;

  $http.get("/data/clones.json")
    .success(function (data) {
      //TODO REMOVE THIS, Simulate latency
      $timeout(function () {
        Notification.success('Clones are loaded');
        $scope.clones = data;
      }, 100);
    })
    .error(function () {
      Notification.error({message: 'Failed to load clones (Status: ' + 500 + ')'})
    });
});