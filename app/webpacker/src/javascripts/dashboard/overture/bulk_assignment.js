$(document).on("turbolinks:load", function () {
  $("#select-options").hide();

  $("#checkedAll").click(function() {
    if ($(this).is(":checked")) {
        $(".checkSingle").prop("checked", true);
    } else {
        $(".checkSingle").prop("checked", false);
    }
    showAssignmentTopBar($(this));
  });

  $(".groupAssignment").click(function(){
    // find the modal body
    let modal = $("#groupAssignPermissions").find(".hidden-assign-forms");
    appendHiddenFieldForm(modal);
  })

  $(".groupDelete").click(function(){
    // find the modal body
    let modal = $("#groupDelete").find(".hidden-forms");
    appendHiddenFieldForm(modal);
  })

  $(".checkSingle").change(function () {
    showAssignmentTopBar($(this));
  });

  // Show assignment topbar when clicking on a single checkbox or the select all checkbox
  function showAssignmentTopBar(thisObj){
    if (thisObj.is(":checked")) {
      $("#filter-search").hide();
      $("#select-options").show();

      if ($(".checkSingle:not(:checked)").length == 0) { //if all is checked
          $("#checkedAll").prop("checked", true);
      }
    }
    else {
      $("#checkedAll").prop("checked", false);
      if($(".checkSingle:checked").length == 0) { //if all is unchecked
          $("#select-options").hide();
          $("#filter-search").show();
      }
    }
    showNumberOfCheckedBox();
  }

  // Show length of checked checkboxes
  function showNumberOfCheckedBox(){
    count = $(".checkSingle:checked").length
    $("#selectedNumber")[0].innerHTML = count + " item(s) selected";
    $("#deleteCount")[0].innerHTML = "Are you sure you would like to delete the selected " + count + " item(s)? This action cannot be undone.";
  }

  // Append hidden field on bulk delete and bulk assignment
  function appendHiddenFieldForm(modal){
    // loop through all the check boxes (class checkbox)
    $(".checkSingle").each(function(index){
      // if they are checked, add permissible id to the modal as a hidden form
      let permissibleId = $(this).closest('tr').data('drawer');
      let permissibleType = $(this).closest('tr').data('permissible-type')
      if($(this).is(":checked")){
        // add a hidden input element to modal with article ID as value
        $(modal).append("<input name='" + permissibleType + "_ids[]' value='"+permissibleId+"'  type='hidden' />")
      }
    });
  }
})
