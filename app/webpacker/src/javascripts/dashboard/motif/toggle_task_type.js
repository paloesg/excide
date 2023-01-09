$(document).on("turbolinks:load", function () {
  if($("#toggle-edit").length){
    if($("#toggle-edit")[0].value == "esign"){
      $("#esign").removeClass("d-none")
      $("#esign-upload").prop("disabled", false)
      $("#esign-hidden").prop("disabled", false)
    } else {
      $("#esign").addClass("d-none")
      // Disable the form fields for documents
      $("#esign-upload").prop("disabled", true)
      $("#esign-hidden").prop("disabled", true)
    }
  }
});

window.toggleTaskType = function(e) {
  if(e.value == "esign"){
    $("#esign").removeClass("d-none")
    $("#esign-upload").prop("disabled", false)
    $("#esign-hidden").prop("disabled", false)
  } else {
    $("#esign").addClass("d-none")
    // Disable the form fields for documents
    $("#esign-upload").prop("disabled", true)
    $("#esign-hidden").prop("disabled", true)
  }
};