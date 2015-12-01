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
        url: "files",
        templateUrl: "views/files.html"
      });
  });