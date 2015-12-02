angular.module('CloneDetection').service('FileService', function ($http, $q) {

  return {
    getFile : function(path) {
      var deferred = $q.defer();
      $http({method: 'GET', url: '/data/files/' + path})
        .success(function(data) {
          debugger;
          if (typeof(data) === "string") {
            deferred.resolve(data);
          } else {
            deferred.resolve(JSON.stringify(data));
          }
        })
        .error(deferred.reject);
      return deferred.promise;
    }
  }
});
