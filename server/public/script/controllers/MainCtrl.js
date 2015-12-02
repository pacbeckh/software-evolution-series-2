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
    problemFile.fragments.forEach(function(fragment) {
      for (var i = fragment.start.line; i <= fragment.end.line; i++) {
          answer.push(i+1);
      }
    });
    answer.sort(function(a,b) {
      return a - b;
    });
    return _.uniq(answer, true);
  };

  var structureClones = function (clones, maintenance) {
    var maintenanceFiles = {};
    maintenance.project.files.forEach(function (file) {
      maintenanceFiles[file.file] = file;
      file.fragments = [];
    });

    var allFragments = clonesToAllFragments(clones);
    allFragments.forEach(function (fragment) {
      maintenanceFiles[fragment.file].fragments.push(fragment);
    });


    var problemFiles = Object.keys(maintenanceFiles)
      .map(function (k) {
        return maintenanceFiles[k]
      }).filter(function (maintenanceFile) {
        return maintenanceFile.fragments.length > 0;
      });

    problemFiles.forEach(function (problemFile) {
      var clonedLineNumbers = getAllLineNumbers(problemFile);

      var problemLines = problemFile.lines.filter(function (effectiveLine) {
        return clonedLineNumbers.indexOf(effectiveLine.number) !== -1;
      });

      problemFile.percentageDuplicated = Math.round(1000 / problemFile.lines.length * problemLines.length) / 10;
    });

    return {
      clones : clones,
      maintenance: maintenance,
      problemFiles : problemFiles,
      maintenanceFiles : maintenanceFiles,
      allFragments : allFragments
    }
  };

  function notifySuccess() {
    $timeout(function () {
      Notification.success('Clones are loaded');
    }, 100)
  }

  var loadMaintenance = function (data) {
    $http.get("/data/maintenance.json").success(function (maintenance) {
      $scope.cloneData = structureClones(data, maintenance);

      $scope.clones = data;

      notifySuccess();
    }).error(function () {
      Notification.error({message: 'Failed to load maintenance (Status: ' + 500 + ')'})
    });
  };

  $http.get("/data/clones.json").success(loadMaintenance).error(function () {
    Notification.error({message: 'Failed to load clones (Status: ' + 500 + ')'})
  });
});