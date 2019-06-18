$(document).ready(function(){
  var clicked = false;
  $(".checkall").on("click", function() {
    var buttonCheckAll = $(this).attr("id");
    var task_id = buttonCheckAll.replace("selectall-","");
    $(".completed-"+task_id).prop("checked", !clicked);
    clicked = !clicked;

    var workflowActionIds = [];
    $(".completed-"+task_id).each(function (index, value){
      workflowActionIds.push($(this).attr("workflow_action"))
    });

    $.post("/symphony/workflow/task/toggle-all", {
      workflow_action_ids: workflowActionIds
    }).done(function() {
      location.reload();
    });
  });
});
