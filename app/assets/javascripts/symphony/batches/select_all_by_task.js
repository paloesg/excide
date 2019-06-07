$(document).ready(function(){
  var clicked = false;
  $(".checkall").on("click", function() {
    var button_checkall = $(this).attr("id")
    var task_id = button_checkall.replace("selectall-","")
    $(".completed-"+task_id).prop("checked", !clicked)
    clicked = !clicked

    var workflow_action_ids = []
    $(".completed-"+task_id).each(function (index, value){
      workflow_action_ids.push($(this).attr("workflow_action"))
    });

    $.post("/symphony/workflow/task/toggle-all", {
      workflow_action_ids: workflow_action_ids
    }).done(function() {
      location.reload()
    });
  });
});