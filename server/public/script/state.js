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
        reloadOnSearch : false
      })
      .state('app.clones', {
        url: "clones/{weight}/{fragments}",
        templateUrl: "views/clones.html"
      });
  });