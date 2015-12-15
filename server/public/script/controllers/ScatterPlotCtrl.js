angular.module('CloneDetection').controller('ScatterPlotCtrl', function ($scope, $timeout) {

  var selectClassesByDataItem = function (uids, clones) {
    $scope.activeClasses = clones.filter(function (cloneClass) {
      return _.contains(uids, cloneClass.uid);
    });
    $scope.activeClasses.forEach(function (e) {
      e.active = false;
    });
    $scope.activeClasses[0].active = true;
  };

  var BUCKET_COUNT = 8;

  $scope.chartConfig = {};

  function generateColors(n) {
    var result = [];

    var colorRange = 100 / (n);

    for (i = 0; i < (n); i++) {
      var R = Math.floor((255 * (colorRange * i)) / 100);
      var G = Math.floor((255 * (100 - (colorRange * i))) / 100);
      var B = 0;

      result.push("rgba(" + R + "," + G + "," + B + ",0.8)");
    }

    return result;
  }


  var chartConfig = function () {
    return {
      options: {
        chart: {
          type: 'scatter',
          height: 550,
          zoomType: 'xy'
        },
        legend: {
          layout: 'horizontal'
        },
        plotOptions: {
          scatter: {
            marker: {
              radius: 5,
              states: {
                hover: {
                  enabled: true,
                  lineColor: 'rgb(100,100,100)'
                }
              }
            },
            animation: false,
            point: {
              events: {
                click: goToClones
              }
            },
            states: {
              hover: {
                marker: {
                  enabled: false
                }
              }
            },
            tooltip: {
              headerFormat: '<b>{series.name} clone classes</b><br>',
              pointFormat: '{point.x} weight</br> {point.y} fragments'
            }
          }
        }
      },
      title: {
        text : ''
      },
      xAxis: {
        allowDecimals: false,
        title: {
          enabled: true,
          text: 'Weight'
        },
        startOnTick: false,
        endOnTick: false,
        showLastLabel: true
      },
      yAxis: {
        title: {
          text: 'Number of fragments'
        },
        endOnTick: false,
        showLastLabel: true
      }
    };
  };

  function goToClones(d) {
    $scope.$state.go("app.clones", {
      weight: this.x,
      fragments: this.y
    });

    return false;
  }

  function createSeries(clones) {
    var mapping = {};
    clones.forEach(function (clazz) {
      mapping[clazz.weight] = mapping[clazz.weight] || [];
      mapping[clazz.weight][clazz.fragments.length] = mapping[clazz.weight][clazz.fragments.length] || [];
      mapping[clazz.weight][clazz.fragments.length].push(clazz.uid);
    });

    var data = {};
    Object.keys(mapping).forEach(function (w) {
      Object.keys(mapping[w]).forEach(function (fs) {
        key = mapping[w][fs].length;
        point = [parseInt(w), parseInt(fs)];
        if (data[key] === undefined) {
          data[key] = {
            name: key,
            data: [point]
          };
        } else {
          data[key].data.push(point);
        }
      });
    });

    var sortedKeys = _.sortBy(_.map(_.keys(data), function (key) {
      return parseInt(key);
    }), function (key) {
      return key;
    });

    var size = sortedKeys.length;
    var bucketSize = Math.floor(size / BUCKET_COUNT);
    var extra = size % BUCKET_COUNT;
    var taken = 0;

    //create separate series for the first bucket.

    var series = [];

    _.take(sortedKeys, bucketSize).forEach(function (key) {
      series.push(data[key]);
    });
    taken += bucketSize;

    while (taken != size) {
      var take = bucketSize;
      if (extra > 0) {
        take += 1;
        extra -= 1;
      }
      var keysToTake = sortedKeys.slice(taken, (taken + take));
      var serie = {
        name: _.first(keysToTake) + " - " + _.last(keysToTake),
        data: []
      };

      keysToTake.forEach(function (key) {
        serie.data = serie.data.concat(data[key].data);
      });

      taken += take;
      series.push(serie);
    }

    var w = $scope.$state.params.weight;
    var fs = $scope.$state.params.fragments;
    if (w && fs) {
      selectClassesByDataItem(mapping[w][fs], clones);
    }

    return series;
  }

  var stop = $scope.$watch('cloneData', function (cloneData) {
    if (cloneData) {
      stop();
      $scope.showChart = false;

      var series = createSeries(cloneData.clones);
      var conf = chartConfig();
      conf.options.colors = generateColors(series.length);
      conf.series = series;

      $scope.chartConfig = conf;
      $timeout(function () {
        $scope.showChart = true;
      }, 5);
    }
  });

});