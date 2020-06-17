$(document).on("turbolinks:load", function() {
  let form = $( ".edit_workflow_action, .multiple_edit" );

  form.on("ajax:success", function(event) {
    const [data, status, xhr] = event.detail;
    $("#check-" + data['workflow_action'].id).show().fadeTo(800, 200, function(){
        $("#check-" + data['workflow_action'].id).fadeTo(200, 0);
    });
  });
});
