window.contactStatusCreate = function(formElement) {
  let formJquery = $(formElement);
  // Get the value of the form
  let formValue = formJquery.val();
  // Find the element that displays the badge and the wording
  let badgeName = formJquery.closest("#edit-status-dropdown").prev().find(".badge-name");
  // Update contact statuses through AJAX
  $.ajax({
    type: "POST",
    url: "/overture/contact_statuses",
    data: formJquery,
    dataType: "JSON"
  }).done(function(data){
    // If form field is :name, change the value (wording) of the badge. Otherwise, if form field is :colour, then change the background of the badge
    if(formElement.id == "status-name"){
      badgeName.html(formValue);
    }
    else{
      badgeName.css("background-color", formValue);
    }
  });
};

$(document).on("turbolinks:load", function () {
  $(".slide-right").click(function () {
    $('.slide-container').scrollLeft(2000);
  });
});
