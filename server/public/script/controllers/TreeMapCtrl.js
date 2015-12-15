angular.module('CloneDetection').controller('TreeMapCtrl', function ($scope) {


    var stop = $scope.$watch('cloneData', function (cloneData) {
        if (cloneData) {
          stop();

          var d3Input = prepareData(cloneData)

          rootFiles = d3Input.children;
          points = createPoints(rootFiles);

          console.log(points);
          $scope.treeMapConfig = createChartConfig(points);
        }
    });

    function prepareData(cloneData){
       var rootFileIndex = -1;

       var pathQuery = $scope.$state.params.pathQuery;
       if(pathQuery){
          rootFileIndex = _.findIndex(cloneData.allFileRefs, 'filePath', pathQuery);
       }

       if(rootFileIndex == -1) {
          rootFileIndex = _.findIndex(cloneData.allFileRefs, function (file){
            return file.path == "src" || file.path == "hsqldb/src"
          });
       }

      var rootFile = angular.copy(cloneData.allFileRefs[rootFileIndex]);
      fixChilds(rootFile.children);
      return rootFile;
    }

    function fixChilds(children){
        children.forEach(function(file){
            if(file.children.length == 0) {
                file.size = Math.sqrt(file.fragments.length);
                delete file.children;
            } else {
                file.children = fixChilds(file.children);
            }
        });
        return children.filter(function (file){
          return (file.size === undefined && file.children && file.children.length > 0 ) || file.size > 0;
        });

      return file;
    }

    function createPoints(files, parent){
      var result = [];
      files.forEach(function (file){
         var point = {
           parent: parent ? parent.path : undefined,
           name: file.name,
           id: file.path
         };
         result.push(point);
        if(file.children){
          result = result.concat(createPoints(file.children, file));
        } else {
          point.value = Math.sqrt(file.fragments.length);
          point.colorValue = Math.sqrt(file.fragments.length);
        }
      });

      return result;
    }

    function createChartConfig(points) {
      return {
        options: {
         colorAxis: {
                 minColor: 'rgb(0,255,0)',
                 maxColor: 'rgb(255,0,0)'
             },

             plotOptions : {
                treemap: {
                 tooltip: {
//                   pointFormat: '{point.value} fragments'
                 },
                 getExtremesFromAll: false
                }
             }
         },
         series: [{
             type: 'treemap',
             layoutAlgorithm: 'squarified',
             allowDrillToNode: true,
             dataLabels: {
                 enabled: false
             },
             levelIsConstant: false,
             levels: [{
                 level: 1,
                 dataLabels: {
                     enabled: true
                 },
                 borderWidth: 2
             }],
             data: points
         }],
         subtitle: {
             text: 'Click points to drill down.'
         },
         title: {
             text: 'Clone distribution'
         }
     }
    }

});