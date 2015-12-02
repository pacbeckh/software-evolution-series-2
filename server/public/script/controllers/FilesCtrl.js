angular.module('CloneDetection').controller('FilesCtrl', function ($scope, $http, $state, $timeout, $uibModal, $location, FileService, Notification) {

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

  var nodeMap = {};

  var registerFilesInNodeMap = function(files, parents) {
    files.forEach(function(node) {
      nodeMap[node.path] = {target: node, parents: parents};
      registerFilesInNodeMap(node.children, [node].concat(parents));
    })
  };

  $scope.dataForTheTree = [];
  $scope.treeOptions = treeOptions;
  $scope.selectedFileContent = null;

  var clonesToAllFragments = function(clones) {
    var answer = [];
    clones.forEach(function(cloneClass) {
      cloneClass.fragments.forEach(function(fragment) {
        answer.push(fragment);
      })
    });
    return answer;
  };

  var loadPath = function (clones, path, selectInTree) {
    if (selectInTree) {
      var nodeInfo = nodeMap[path];
      if (nodeInfo) {
        $scope.selectedNode = nodeInfo.target;
        $scope.expandedNodes = nodeInfo.parents;
      }
    }

    if (path.match(/^\.\//)) {
      path = path.substr(2);
    }
    var highlightedLines = clonesToAllFragments(clones).filter(function(fragment) {
      return fragment.file == path;
    }).map(function(fragment) {
      return fragment.start.line
    });

    FileService.getFile(path).then(function (data) {
      $scope.selectedFileContent = data;

      $scope.editorOptions = {
        lineWrapping: true,
        lineNumbers: true,
        readOnly: 'nocursor',
        mode: 'clike',
        onLoad: function () {
          $timeout(function () {
            var refs = $(".CodeMirror-linenumber[style]");
            highlightedLines.forEach(function (line) {
              refs.eq(line - 1)
                .css('background', '#BB5252')
                .css('color', '#fff');

              refs.eq(line).on('click', function () {
                $scope.$apply(function () {
                  $uibModal.open({
                    templateUrl: './templates/clone-classes-modal.html',
                    animation: true
                  });
                });
              })
            })
          }, 10);
        }
      };
    }, function() {
      Notification.error({message : "Failed to load file: " + path});
    });
  };

  $scope.showSelected = function (node) {
    $scope.selectedFile = node.path;
    $location.search("path", node.path);
    $scope.selectedFileContent = null;
    loadPath($scope.clones,node.path, false);
  };

  $scope.toggleExpand = function () {
    $scope.expandedTree = !$scope.expandedTree;
  };


  ////////////////////////////////
  init();

  function init() {
    $scope.expandedTree = false;

    $http.get('/files').success(function (data) {
      $scope.dataForTheTree = data;
      registerFilesInNodeMap(data, []);

      var stop = $scope.$watch('clones', function(clones) {
        if (clones) {
          stop();
          if ($state.params.path) {
            var path = decodeURIComponent($state.params.path);
            loadPath(clones, path, true);
          }
        }
      });
    });
  }
});