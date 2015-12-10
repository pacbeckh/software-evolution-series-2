angular.module('CloneDetection').controller('DonutCtrl', function($scope, DonutService) {

    var stop = $scope.$watch('cloneData', function(cloneData) {
        if (cloneData) {
            stop();
            data = createDonutData(cloneData);
            DonutService.render(data);
        }
    })

    function createDonutData(cloneData){
        result = {};

//        // Also show files with no imports
//        cloneData.allFileRefs.forEach(function(fileRef){
//            if(!fileRef.isDir && fileRef.path.indexOf("src/") >= 0 ){
//                result[fileRef.path] = {
//                    name : fileRef.path,
//                    imports : new Set()
//                }
//            }
//        });

        cloneData.clones.forEach(function(clone) {
            files = _.uniq(clone.fragments.map(function(fragment){
                return fragment.file;
            }));


            for (i = 0; i < files.length; i++) {
                if(result[files[i]] === undefined){
                    result[files[i]] = {
                       name : files[i],
                       imports : new Set()
                   }
                }

                for (j = i + 1; j < files.length; j++){
                    result[files[i]].imports.add(files[j]);
                }
            }
        });

//        // Remove the .java suffix
//        _.forEach(result, function(resultItem){
//            resultItem.name = fixFileName(resultItem.name);
//            resultItem.imports = Array.from(resultItem.imports).map(function(name){return fixFileName(name);});
//        });

        return _.values(result);
    }

    function fixFileName(name){
        return name.substring(0, name.lastIndexOf("."));
    }

});