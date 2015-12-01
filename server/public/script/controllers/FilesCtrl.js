angular.module('CloneDetection').controller('FilesCtrl', function ($scope, $http, $state, $timeout, $uibModal) {

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

  var highlightedLines = [
    1,4,21
  ];

  var loadPath = function(path) {
    $http({method: 'GET', url: '/data/files/' + path}).success(function (data) {
      $scope.selectedFileContent = data;

      $scope.editorOptions = {
        lineWrapping: true,
        lineNumbers: true,
        readOnly: 'nocursor',
        mode: 'clike',
        onLoad : function() {
          $timeout(function() {
            var refs = $(".CodeMirror-linenumber");
            highlightedLines.forEach(function(line) {
              refs.eq(line)
                .css('background', '#BB5252')
                .css('color', '#fff');

              refs.eq(line).on('click',function(e) {
                $scope.$apply(function() {
                  $uibModal.open({
                    templateUrl : './templates/clone-classes-modal.html',
                    animation : true
                  });
                });
              })
            })
          }, 10);
        }
      };
    });
  };

  $scope.showSelected = function (node) {
    $state.go('app.files', {path: node.path});
    $scope.selectedFile = node.path;
    $scope.selectedFileContent = null;
    loadPath(node.path);
  };


  ////////////////////////////////
  init();

  function init() {
    if ($state.params.path) {
      var path = decodeURIComponent($state.params.path);
      loadPath(path);
    }

  }
});