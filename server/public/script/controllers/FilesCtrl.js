angular.module('CloneDetection').controller('FilesCtrl', function ($scope, $http) {

  $scope.expandedTree = false;
  var treeOptions = {
    nodeChildren: "children",
    dirSelectable: false,
    injectClasses: {
      ul: "a1",
      li: "a2",
      liSelected: "a7",
      iExpanded: "a3",
      iCollapsed: "a4",
      iLeaf: "a5",
      label: "a6",
      labelSelected: "a8"
    }
  };

  $http.get('/files').success(function (data) {
    $scope.dataForTheTree = data;
  });

  $scope.dataForTheTree = [];
  $scope.treeOptions = treeOptions;
  $scope.selectedFileContent = null;

  $scope.showSelected = function (node) {
    $scope.selectedFile = node.path;
    $scope.selectedFileContent = null;
    $http({method: 'GET', url: '/data/files/' + node.path}).success(function (data) {
      $scope.selectedFileContent = data;

      $scope.editorOptions = {
        lineWrapping: true,
        lineNumbers: true,
        readOnly: 'nocursor',
        mode: 'clike'
      };
    })
  }

});