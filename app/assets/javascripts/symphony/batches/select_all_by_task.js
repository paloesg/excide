document.addEventListener("turbolinks:load", function(){
  var clicked = false;
  $(".checkall").on("click", function() {
    var buttonCheckAll = $(this).attr("id");
    var taskId = buttonCheckAll.replace("selectall-","");
    $(".completed-"+taskId).prop("checked", !clicked);
    clicked = !clicked;

    var workflowActionIds = [];
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
