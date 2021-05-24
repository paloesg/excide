$(document).on("turbolinks:load", function () {
    $("#version_control_valid_file" ).change(function() {
        if (document.getElementById("version_control_valid_file").value != "") {
            $("#vc_submit_button").attr("disabled", false);
        }
        else if (document.getElementById("version_control_valid_file").value == "") {
            $("#vc_submit_button").attr("disabled", true);
        }
    });
});