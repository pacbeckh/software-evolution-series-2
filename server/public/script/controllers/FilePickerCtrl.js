angular.module('CloneDetection').controller('FilePickerCtrl', function ($scope, allFileRefs) {
  $scope.searchQuery = null;


  function createFilter(query) {
    if (!query) {
      return {
        valid: true, filter: function () {
          return true;
        }
      }
    }

    try {
      var exp = new RegExp($scope.searchQuery, 'i');

      return {
        valid: true, filter: function (item) {
          return item.name.match(exp);
        }
      };
    } catch(e) {
      return {
        valid: false, filter: function () {
          return false;
        }
      };

    }
  }

  $scope.updateResults = function () {
    var filterData = createFilter($scope.searchQuery);

    $scope.validRegex = filterData.valid;
    var answer = allFileRefs.filter(filterData.filter);
    $scope.resultCount = answer.length;
    $scope.results = answer.slice(0, 10);
  };
  $scope.updateResults();

  $scope.openFile = function (item) {
    $scope.$close(item);
  }
});