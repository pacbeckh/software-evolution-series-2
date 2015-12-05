angular.module('CloneDetection').directive('fileSnippetLoader', function (FileService) {

  var promises = {};

  return {
    templateUrl : './templates/file-snippet-loader.html',
    scope : {
      location: '='
    },
    link : function($scope) {
      $scope.loading = true;

      var promise;
      if (promises[$scope.location.file]) {
        promise = promises[$scope.location.file];
      } else {
        promise = FileService.getFile($scope.location.file);
        promises[$scope.location.file] = promise;
      }

      promise.then(function(content) {
        var rows = content.split("\n").slice(($scope.location.start.line - 1), $scope.location.end.line);
        $scope.previewContent = rows.join("\n");
        $scope.loading = false;
      })
    },
    controller : function($scope) {
      $scope.snippetOpts = {
        lineWrapping: true,
        lineNumbers: true,
        readOnly: 'nocursor',
        mode: 'clike',
        firstLineNumber: $scope.location.start.line
      };
    }
  }
});