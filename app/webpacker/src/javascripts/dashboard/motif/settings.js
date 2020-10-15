$(document).on("turbolinks:load", function () {
  $("select.motif-select-user-types").change(function(){
    console.log("What is this?", $(this).val());
    console.log("What is user id?", $(this).attr('id'));
    $.ajax({
      type: "PATCH",
      url: "/motif/users/" + $(this).attr('id'),
      data: {
        role_id: $(this).val(),
      },
      dataType: "JSON"
    })
  })
});
