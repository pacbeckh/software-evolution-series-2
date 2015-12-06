angular.module('CloneDetection').controller('MainCtrl', function ($scope, $state, $http, $timeout, Notification) {
  $scope.$state = $state;

  var clonesToAllFragments = function (clones) {
    var answer = [];
    clones.forEach(function (cloneClass) {
      cloneClass.fragments.forEach(function (fragment) {
        answer.push(fragment);
      })
    });
    return answer;
  };

  var getAllLineNumbers = function (problemFile) {
    var answer = [];
    problemFile.target.fragments.forEach(function (fragment) {
      for (var i = fragment.start.line; i <= fragment.end.line; i++) {
        answer.push(i + 1);
      }
    });
    answer.sort(function (a, b) {
      return a - b;
    });
    return _.uniq(answer, true);
  };

  var calculateContainingFragments = function(files) {
    var count = 0;
    files.forEach(function(file) {
      var c = calculateContainingFragments(file.children);
      file.containingFragments = c + file.fragments.length;
      count += file.containingFragments;
    });
    return count;
  };

  var processFileTree = function (files) {
    var result = {};
    var registerFilesInNodeMap = function (files, parents) {
      files.forEach(function (node) {
        node.fragments = [];
        result[node.path] = {target: node, parents: parents};
        registerFilesInNodeMap(node.children, [node].concat(parents));
      });
    };

    registerFilesInNodeMap(files, []);
    return result;
  };

  var structureClones = function (clones, maintenance, files) {
    var maintenanceFiles = processFileTree(files);
    maintenance.project.files.forEach(function (file) {
      maintenanceFiles[file.file].maintenance = file;
    });

    var allFragments = clonesToAllFragments(clones);
    allFragments.forEach(function (fragment) {
      maintenanceFiles[fragment.file].target.fragments.push(fragment);
    });


    var problemFiles = Object.keys(maintenanceFiles)
      .map(function (k) {
        return maintenanceFiles[k]
      }).filter(function (maintenanceFile) {
        return maintenanceFile.target.fragments.length > 0;
      });

    problemFiles.forEach(function (problemFile) {
      var clonedLineNumbers = getAllLineNumbers(problemFile);

      var problemLines = problemFile.maintenance.lines.filter(function (effectiveLine) {
        return clonedLineNumbers.indexOf(effectiveLine.number) !== -1;
      });

      problemFile.percentageDuplicated = Math.round(1000 / problemFile.maintenance.lines.length * problemLines.length) / 10;
    });

    calculateContainingFragments(files);

    return {
      clones: clones,
      maintenance: maintenance,
      problemFiles: problemFiles,
      maintenanceFiles: maintenanceFiles,
      allFragments: allFragments,
      files: files
    }
  };

  function notifySuccess() {
    $timeout(function () {
      Notification.success('Clones are loaded');
    }, 100)
  }

  var loadFiles = function (data, maintenance) {
    $http.get('/files').success(function (files) {
      $scope.cloneData = structureClones(data, maintenance, files);
      $scope.clones = data;
      notifySuccess();
    });
  };

  var loadMaintenance = function (data) {
    $http.get("/data/maintenance.json").success(function (maintenance) {
      loadFiles(data, maintenance);
    }).error(function () {
      Notification.error({message: 'Failed to load maintenance (Status: ' + 500 + ')'})
    });
  };

  $http.get("/data/clones.json").success(loadMaintenance).error(function () {
    Notification.error({message: 'Failed to load clones (Status: ' + 500 + ')'})
  });
});