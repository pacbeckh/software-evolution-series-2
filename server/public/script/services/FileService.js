angular.module('CloneDetection').service('FileService', function ($http, $q) {

  return {
    getFile : function(path) {
      var deferred = $q.defer();
      $http({method: 'GET', url: '/data/files/' + path})
        .success(deferred.resolve)
        .error(deferred.reject);
      return deferred.promise;
    }
  }
});
