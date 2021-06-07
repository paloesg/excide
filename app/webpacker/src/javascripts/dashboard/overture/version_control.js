$(document).on("turbolinks:load", function () {  
  $(".custom-file-input").change(function() {
    submit_form_group = $(this).closest("#row1").siblings(".form-group").children();
    if ($(this).val() != "") {
      $(submit_form_group).attr("disabled", false);
    }
  });
});
