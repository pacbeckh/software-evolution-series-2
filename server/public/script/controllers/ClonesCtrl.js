angular.module('CloneDetection').controller('ClonesCtrl', function ($scope, ScatterPlotService) {
  //var data = [
  //  { fragments : 2, weight: 3, size : 2}
  //];

  var clones = [
    {
      uid: '1',
      weight: 8,
      fragments: [
        {file: './node_modules/express/History.md', start: 12, end: 18},
        {file: './node_modules/express/History.md', start: 13, end: 19},
        {file: './node_modules/express/History.md', start: 14, end: 20},
        {file: './node_modules/express/History.md', start: 15, end: 21}
      ]
    },
    {
      uid: '2',
      weight: 8,
      fragments: [
        {file: './node_modules/express/History.md', start: 12, end: 18},
        {file: './node_modules/express/History.md', start: 12, end: 18},
        {file: './node_modules/express/History.md', start: 12, end: 18},
        {file: './node_modules/express/History.md', start: 12, end: 18}
      ]
    },
    {
      uid: '3',
      weight: 3,
      fragments: [
        {file: './node_modules/express/History.md', start: 12, end: 18},
        {file: './node_modules/express/History.md', start: 12, end: 18}
      ]
    },
    {
      uid: '4',
      weight: 4,
      fragments: [
        {file: './node_modules/express/History.md', start: 12, end: 18},
        {file: './node_modules/express/History.md', start: 12, end: 18},
        {file: './node_modules/express/History.md', start: 12, end: 18}
      ]
    }
  ];

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

  var selectClassesByDataItem = function(node) {
    $scope.activeClasses = clones.filter(function(cloneClass) {
      return node.uids.indexOf(cloneClass.uid) != -1;
    });
    $scope.activeClasses.forEach(function(e) {
      e.active = false;
    });
    $scope.activeClasses[0].active = true;
  };

  ScatterPlotService.render("#class-scatter-plot", data, function(node) {
    $scope.$state.go("app.clones", {weight: node.weight, fragments : node.fragments});
  });

  if ($scope.$state.params.weight && $scope.$state.params.fragments) {
    var selectedByUrl = data.filter(function(item) {
      return item.weight == $scope.$state.params.weight && item.fragments == $scope.$state.params.fragments;
    })[0];
    selectClassesByDataItem(selectedByUrl);
  }

});