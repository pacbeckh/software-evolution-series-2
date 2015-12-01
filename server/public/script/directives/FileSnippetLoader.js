angular.module('CloneDetection').directive('fileSnippetLoader', function (FileService) {

  var promises = {};

  return {
    templateUrl : './templates/file-snippet-loader.html',
    scope : {
      location: '='
    },
    link : function($scope) {
      $scope.loading = true;

      //$scope.editorOptions.firstLineNumber = $scope.location.start;

      var promise = FileService.getFile($scope.location.file);
      promises[$scope.location.file] = promise;
      promise.then(function(content) {
        var rows = content.split("\n").slice(($scope.location.start - 1), $scope.location.end);
        $scope.previewContent = rows.join("\n");
      })
    },
    controller : function($scope) {
      console.log("OAt");
      $scope.snippetOpts = {
        lineWrapping: true,
        lineNumbers: true,
        readOnly: 'nocursor',
        mode: 'clike',
        firstLineNumber: $scope.location.start
      };
    }
  }
});