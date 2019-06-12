$(document).ready(function() {
  const $form = $( ".edit_workflow_action, .multiple_edit" );

  $form.on("ajax:success", function(event, xhr, settings) {
    $("#check-" + xhr.id).show().fadeTo(500, 200, function(){
        $("#check-" + xhr.id).fadeTo(200, 0);
    });
    $("#remarks-" + xhr.id).text(xhr.remarks);
  });
});