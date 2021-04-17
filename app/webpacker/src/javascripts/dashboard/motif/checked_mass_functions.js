// This js is to assign methods to checked documents in communication hub
$(document).on("turbolinks:load", function () {
  console.log("It working checked!");
  $("#select-options").hide();

  $("#checkedAll").change(function() {
    if ($(this).is(":checked")) {
      console.log("What is checksingle",  $(".checkSingle"))
      $(".checkSingle").prop("checked", true).change();
    } else {
      $(".checkSingle").prop("checked", false).change();
    }
  });

  $(".groupDelete").click(function(){
    // find the modal body
    let modal = $("#groupDelete").find(".hidden-forms");
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
  })

  $(".checkSingle").change(function () {
    if ($(this).is(":checked")) {
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
  });

  $("#clearSelect").click(function () {
    $("#checkedAll").prop("checked", false).change();
  })

  function showNumberOfCheckedBox(){
    count = $(".checkSingle:checked").length
    $("#selectedNumber")[0].innerHTML = count + " item(s) selected";
    $("#deleteCount")[0].innerHTML = "You are going to delete " + count + " item(s). It can’t be undone. Confirm to delete?";
  }
})
