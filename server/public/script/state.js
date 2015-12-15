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
        reloadOnSearch: false,
        skipContainer: true
      })
      .state('app.clones', {
        url: "clones/{weight}/{fragments}",
        templateUrl: "views/scatterplot.html",
        reloadOnSearch: false
      })
      .state('app.problems', {
        url: "problems",
        templateUrl: "views/problems.html"
      })
      .state('app.graphs', {
        url: 'graphs',
        abstract: true,
        template: '<div ui-view></div>'
      })
      .state('app.graphs.file-tree', {
        url: "/file-tree",
        templateUrl: "views/file-tree-graph.html"
      })
      .state('app.graphs.type-packing', {
        url: "/type-packing/:cloneId",
        templateUrl: "views/type-packing.html"
      })
      .state('app.graphs.donut', {
        url: "/donut",
        templateUrl: "views/donut.html",
        skipContainer: true
      })
      .state('app.graphs.treemap',
      {
        url: "/treemap",
        templateUrl: "views/treemap.html"
      });

  });