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

  $scope.dataForTheTree = [];
  $scope.treeOptions = treeOptions;
  $scope.selectedFileContent = null;

  var clonesToAllFragments = function (clones) {
    var answer = [];
    clones.forEach(function (cloneClass) {
      cloneClass.fragments.forEach(function (fragment) {
        fragment.cloneClass = cloneClass;
        answer.push(fragment);
      })
    });
    return answer;
  };

  var cloneFragmentClickCallback = function (fragments, lineStart) {
    return function () {
      $uibModal.open({
        templateUrl: './templates/clone-classes-modal.html',
        animation: true,
        size: 'lg',
        controller: 'ModalCtrl',
        resolve: {
          cloneClasses: function () {
            return fragments.map(function (fragment) {
              return fragment.cloneClass;
            });
          }
        }
      });
    };
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

    var highlightedLines = clonesToAllFragments(clones).filter(function (fragment) {
      return fragment.file == path;
    });
    var groupedHighLights = _.groupBy(highlightedLines, function (fragment) {
      return fragment.start.line;
    });

    function addHighlightsWhenLineVisible() {
      var refs = $(".CodeMirror-linenumber[style]");
      var allPresent = _.all(groupedHighLights, function (fragments, lineStart) {
        return refs.eq(lineStart - 1).length > 0;
      });

      if (allPresent) {
        addHighlights(refs);
      } else {
        $timeout(function () {
          addHighlightsWhenLineVisible();
        }, 200);
      }
    }

    function addHighlights(refs) {
      _.each(groupedHighLights, function (fragments, lineStart) {
        refs.eq(lineStart - 1).on('click', function () {
          $scope.$apply(cloneFragmentClickCallback(fragments, lineStart));
        });


        refs.eq(lineStart - 1)
          .css('background', '#BB5252')
          .css('color', '#fff')
          .css('z-index', lineStart)
          .css('cursor', 'pointer')
      })
    }

    FileService.getFile(path).then(function (data) {
      $scope.selectedFileContent = data;

      $scope.editorOptions = {
        lineWrapping: true,
        lineNumbers: true,
        readOnly: true,
        mode: 'clike',
        onLoad: function () {
          $timeout(addHighlightsWhenLineVisible, 10);
        }
      };
    }, function () {
      Notification.error({message: "Failed to load file: " + path});
    });
  };

  $scope.showSelected = function (node, opts) {
    opts = opts || {};

    $scope.selectedFile = node.path;
    $location.search("path", node.path);
    $scope.selectedFileContent = null;
    loadPath($scope.clones, node.path, opts && opts.open);
  };

  $scope.toggleExpand = function () {
    $scope.expandedTree = !$scope.expandedTree;
  };

  var modal = null;
  $scope.$on('KEY_PRESS', function (event, data) {
    if (data.keyCode == 190 && !modal) {

      modal = $uibModal.open({
        templateUrl: './templates/file-picker-modal.html',
        animation: true,
        size: 'lg',
        controller: 'FilePickerCtrl',
        resolve: {
          allFileRefs: function () {
            return $scope.cloneData.allFileRefs.filter(function (item) {
              return !item.isDir;
            });
          }
        }
      });

      modal.result.then(function (item) {
        $scope.showSelected(item, {open: true});
        modal = null;
      }, function () {
        modal = null;
      })

    }
  });

  ////////////////////////////////
  init();

  function init() {
    $scope.expandedTree = false;

    var stop = $scope.$watch('cloneData', function (cloneData) {
      if (cloneData) {
        stop();

        $scope.dataForTheTree = cloneData.files;
        nodeMap = cloneData.maintenanceFiles;
        //registerFilesInNodeMap(cloneData.files, []);

        if ($state.params.path) {
          var path = decodeURIComponent($state.params.path);
          loadPath(cloneData.clones, path, true);
        }
      }
    });
  }

});