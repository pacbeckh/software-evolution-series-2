angular.module('CloneDetection').controller('TypePackingCtrl', function ($scope, CirclePackingService) {

  if ($scope.$state.params.cloneId) {
    var stop = $scope.$watch('cloneData', function (cloneData) {
      if (cloneData) {
        stop();
        var targetClone = cloneData.clones.filter(function (item) {
          return item.uid === $scope.$state.params.cloneId;
        })[0];

        var data = cloneClassToCloneClassTypes(cloneData, targetClone);
        CirclePackingService.render(data);
      }
    });
  }


  function cloneClassToCloneClassTypes(cloneData, targetClone) {
    var result = {};

    targetClone.fragments.forEach(function (fragment) {
      var key = fragmentToContent(fragment, cloneData);
      result[key] = result[key] || [];
      result[key].push(fragment);
    });

    var segment = 0;
    var typeOneGroups = Object.keys(result).map(function(k) {

      result[k].forEach(function() {

      });

      return {
        name : "Segment " + (++segment),
        children : result[k].map(function(fragment) {
          return {
            name : fragment.fileName,
            size : 1000
          }
        })
      }
    });

    return {
      name: "Clone Classes",
      children: typeOneGroups
    }
  }

  function fragmentToContent(fragment, cloneData) {
    var maintenanceFile = cloneData.maintenance.project.files.filter(function (i) {
      return i.file == fragment.file;
    })[0];

    var lines = maintenanceFile.lines.filter(function (line) {
      //debugger;
      return fragment.start.line <= line.number &&
        fragment.end.line >= line.number;
    });

    var contents = lines.map(function(l) {
      return l.content.trim();
    });
    return contents.join('\n');
  }
});