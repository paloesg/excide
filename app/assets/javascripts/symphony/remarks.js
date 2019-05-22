$(document).ready(function() {
  const $form = $( '.edit_workflow_action' );

  $form.on('ajax:success', function(event, xhr, settings) {
    var jsonData = JSON.parse(xhr);
    $("#check-" + jsonData.id).show().fadeTo(500, 200, function(){
        $("#check-" + jsonData.id).fadeTo(200, 0);
    });
    $("#remarks-" + jsonData.id).text(jsonData.remarks);
  });
});