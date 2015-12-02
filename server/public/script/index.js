angular.module('CloneDetection', [
  'ui.codemirror',
  'ui.bootstrap',
  'ui-notification',
  'treeControl',
  'CloneDetection.states'
]).config(function(NotificationProvider) {
  NotificationProvider.setOptions({
    delay: 10000,
    startTop: 20,
    startRight: 10,
    verticalSpacing: 20,
    horizontalSpacing: 20,
    positionX: 'left',
    positionY: 'bottom'
  });
}).run(function () {
  console.log("Angular: Clone Detection has started");
});
