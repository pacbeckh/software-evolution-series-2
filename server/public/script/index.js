angular.module('CloneDetection', [
  'ui.codemirror',
  'ui.bootstrap',
  'ui-notification',
  'treeControl',
  'CloneDetection.states',
  'highcharts-ng'
]).run(function () {
  console.log("Angular: Clone Detection has started");
});
