angular.module('CloneDetection').controller('GraphsCtrl', function ($scope, $state, $http, $timeout, Notification) {

  var getNodes = function (cloneClasses, classUid) {
    var targetClass = cloneClasses.filter(function (cloneClass) {
      return cloneClass.uid == classUid;
    })[0];
    return targetClass.fragments.map(function (fragment) {
      var components = fragment.file.split('/');
      return {
        name: components.pop(),
        folders: fragment.file.split('/'),
        group: 1
      };
    });
  };

  var getDistance = function (left, right) {
    var i = 0;
    for (i = 0; i < Math.min(left.folders.length, right.folders.length); i++) {
      if (left.folders[i] != right.folders[i]) {
        break;
      }
    }
    return (((left.folders.length - i) + (right.folders.length - i)) + 1) * 60;
    //return 30;
  };

  var getLinks = function (nodes) {
    var answer = [];
    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        var distance = getDistance(nodes[i], nodes[j]);
        console.log(distance);

        answer.push({source: i, target: j, value: 1, distance: distance})
      }
    }
    return answer;
  };

  ////////////////////////////////
  init();

  function init() {
    if ($scope.$state.params.class) {
      var stop = $scope.$watch('clones', function (cloneClasses) {
        if (cloneClasses) {
          stop();
          var nodes = getNodes(cloneClasses, $scope.$state.params.class);
          var links = getLinks(nodes);
          //renderShizzle(nodes, links);
        }
      });
    }
  }
});