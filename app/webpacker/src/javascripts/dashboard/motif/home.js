$(document).on("turbolinks:load", function () {
  $("#select-options").hide();

  $("#checkedAll").change(function() {
    if ($(this).is(":checked")) {
        $(".checkSingle").prop("checked", true).change();
    } else {
        $(".checkSingle").prop("checked", false).change();
    }
  });
  $(".group-folder").click(function(){
    console.log(" I AM CLICKED")
    // find the modal body
    let modal = $("#checkedFolderUpload").find(".hidden-forms");  
    console.log("WHAT IS MODAL", modal);  
    // loop through all the check boxes (class checkbox)
    $(".checkSingle").each(function(index){
      // if they are checked, add permissible id to the modal as a hidden form
      let permissibleId = $(this).closest('tr').data('drawer');

      if($(this).is(":checked")){
        // add a hidden input element to modal with article ID as value
        $(modal).append("<input name='permissible_ids[]' value='"+permissibleId+"'  type='hidden' />")
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
    $("#selectedNumber")[0].innerHTML = count + " selected";
    $("#deleteCount")[0].innerHTML = "Delete these " + count + " items?";
  }
})
