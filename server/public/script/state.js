angular
  .module('CloneDetection.states', ['ui.router'])
  .config(function ($stateProvider, $urlRouterProvider) {
    //
    // For any unmatched url, redirect to /state1
    $urlRouterProvider.otherwise("/");
    //
    // Now set up the states
    $stateProvider
      .state('app', {
        url: "/",
        templateUrl: "views/root.html"
      })
      .state('app.files', {
        url: "files?path",
        templateUrl: "views/files.html",
        reloadOnSearch : false,
        skipContainer : true
      })
      .state('app.clones', {
        url: "clones/{weight}/{fragments}",
        templateUrl: "views/clones.html"
      })
      .state('app.problems', {
        url: "problems",
        templateUrl: "views/problems.html"
      })
      .state('app.graphs', {
        url : 'graphs',
        abstract : true,
        template : '<div ui-view></div>'
      })
      .state('app.graphs.file-tree', {
        url: "/file-tree",
        templateUrl: "views/file-tree-graph.html"
      });
  });