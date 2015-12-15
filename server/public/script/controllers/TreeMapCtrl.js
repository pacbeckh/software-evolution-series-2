angular.module('CloneDetection').controller('TreeMapCtrl', function ($scope, $timeout) {


    $scope.loading = true;

    var stop = $scope.$watch('cloneData', function (cloneData) {
        if (cloneData) {
          stop();

          var rootFiles = prepareData(cloneData).children;

          var problemFileIndex = {};
          cloneData.problemFiles.forEach(function(file) {
            problemFileIndex[file.maintenance.file] = file;
          });

          var points = createPoints(problemFileIndex, rootFiles);


          $scope.treeMapConfig = createChartConfig(points);
          $timeout(function() {
            $scope.loading = false;
          }, 5);
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
                delete file.children;
            } else {
                file.children = fixChilds(file.children);
            }
        });
        return children.filter(function (file){
          return (file.children && file.children.length > 0 ) || file.fragments.length > 0;
        });

      return file;
    }

    function createPoints(problemFileIndex, files, parent){
      var result = [];
      files.forEach(function (file){
         var point = {
           parent: parent ? parent.path : undefined,
           name: file.name,
           id: file.path
         };
         result.push(point);
        if(file.children){
          result = result.concat(createPoints(problemFileIndex, file.children, file));
        } else {
          point.value = problemFileIndex[file.path].maintenance.LOC;
          point.colorValue = problemFileIndex[file.path].percentageDuplicated;
          //point.colorValue = file.fragments.length;
        }
      });

      return result;
    }

    function createChartConfig(points) {
      return {
        options: {
         colorAxis: {
                 minColor: '#45B700',
                 maxColor: '#FF0000'
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