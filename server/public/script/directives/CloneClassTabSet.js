angular.module('CloneDetection').directive('cloneClassTabSet', function () {

  return {
    templateUrl: './templates/clone-class-tab-set.html',
    scope: {
      cloneClasses: '='
    }
  }
});