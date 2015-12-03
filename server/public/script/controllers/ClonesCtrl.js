angular.module('CloneDetection').controller('ClonesCtrl', function ($scope, ScatterPlotService) {

  var selectClassesByDataItem = function (node, clones) {
    $scope.activeClasses = clones.filter(function (cloneClass) {
      return node.uids.indexOf(cloneClass.uid) != -1;
    });
    $scope.activeClasses.forEach(function (e) {
      e.active = false;
    });
    $scope.activeClasses[0].active = true;
  };

  var setupScatterPlot = function(clones) {
    var mapping = {};

    clones.forEach(function (clazz) {
      mapping[clazz.weight] = mapping[clazz.weight] || {};
      mapping[clazz.weight][clazz.fragments.length] = mapping[clazz.weight][clazz.fragments.length] || [];
      mapping[clazz.weight][clazz.fragments.length].push(clazz);
    });

    var data = [];
    Object.keys(mapping).forEach(function (w) {
      Object.keys(mapping[w]).forEach(function (fs) {
        data.push({
          weight: w,
          fragments: fs,
          size: mapping[w][fs].length,
          uids: mapping[w][fs].map(function (cl) {
            return cl.uid;
          })
        });
      });
    });

    //debugger;

    ScatterPlotService.render("#class-scatter-plot", data, function (node) {
      $scope.$state.go("app.clones", {weight: node.weight, fragments: node.fragments});
    });

    if ($scope.$state.params.weight && $scope.$state.params.fragments) {
      var selectedByUrl = data.filter(function (item) {
        return item.weight == $scope.$state.params.weight && item.fragments == $scope.$state.params.fragments;
      })[0];
      selectClassesByDataItem(selectedByUrl, clones);
    }
  };


  ////////////////////////////////
  init();

  function init() {
    var stop = $scope.$watch('cloneData', function(cloneData) {
      if (cloneData) {
        stop();
        setupScatterPlot(cloneData.clones);
      }
    });

    //if($scope.clones) {
    //  setupScatterPlot($scope.clones);
    //  debugger;
    //} else {
    //  debugger;
    //}

  }
});