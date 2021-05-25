$(document).on("turbolinks:load", function () {
  $("#version_control_valid_file").change(function() {
    if ($("#version_control_valid_file").val() != "") {
      $("#vc_submit_button").attr("disabled", false);
    }
    else {
      $("#vc_submit_button").attr("disabled", true);
    }
  });
});