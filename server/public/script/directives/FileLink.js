angular.module('CloneDetection').directive('fileLink', function () {

  return {
    template: '<a data-ui-sref="app.files({path:path})">{{fileName}}</a>',
    scope: {
      path: '='
    },
    link: function (scope) {
      scope.fileName = scope.path.substring(scope.path.lastIndexOf("/") + 1);
    }
  }
});