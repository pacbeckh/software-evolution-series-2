angular.module('CloneDetection').controller('TreeMapCtrl', function ($scope, TreeMapService) {

    var stop = $scope.$watch('cloneData', function (cloneData) {
        if (cloneData) {
          console.log(cloneData);
          var input = prepareData(cloneData)

          stop();
          TreeMapService.render(input);
        }
      });


    function prepareData(cloneData){
      var files = cloneData.files.filter(function (x) {
        return x.name === "src";
      });

      var filesCopy = angular.copy(files);

      result = filesCopy.map(function (x) {
        return fixChilds(x);
      });

      console.log(result);

      return result[0];
    }

    function fixChilds(file){
      if(file.children.length == 0){
        file.size = file.fragments.length;
        delete file.children;
      }else{
        file.children = file.children.map(function(child){
           return fixChilds(child);
        }).filter(function (child){
          return !child.size || child.size > 0;
        });
      }
      return file;
    }
});