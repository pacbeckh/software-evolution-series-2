angular.module('CloneDetection').directive('fileSnippetLoader', function (FileService, $timeout, $interval) {

  var promises = {};

  return {
    templateUrl : './templates/file-snippet-loader.html',
    scope : {
      location: '='
    },
    controller : function($scope) {
      $scope.loading = true;
      $scope.counter = 0;
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
        $timeout(function() {
          $scope.loading = false;
          $timeout(function() {
            $scope.counter += 1;
          }, 50);
        }, 50);
      });

      $scope.snippetOpts = {
        lineWrapping: true,
        lineNumbers: true,
        readOnly: true,
        mode: 'clike',
        firstLineNumber: $scope.location.start.line
      };
    }
  }
});