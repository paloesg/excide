$(document).on('turbolinks:load', function(){
  let clicked = false;
  $(".checkall").on("click", function() {
    let buttonCheckAll = $(this).attr("id");
    let taskId = buttonCheckAll.replace("selectall-","");
    $(".completed-"+taskId).prop("checked", !clicked);
    clicked = !clicked;

    let workflowActionIds = [];
    $(".completed-"+taskId).each(function (index, value){
      workflowActionIds.push($(this).attr("workflow_action"));
    });

    $.post("/symphony/workflow/task/toggle-all", {
      workflow_action_ids: workflowActionIds
    }).done(function() {
      location.reload();
    });
  });
});
