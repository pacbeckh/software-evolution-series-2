angular.module('CloneDetection').controller('DonutCtrl', function($scope, DonutService) {

    var stop = $scope.$watch('cloneData', function(cloneData) {
        if (cloneData) {
            stop();
            DonutService.render(cloneData);
        }
    })

});