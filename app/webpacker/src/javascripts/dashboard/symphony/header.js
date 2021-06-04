
$(document).on("turbolinks:load", function(){
  let len = $('.break-inside-avoid').length;
  let remainder = len%10;
  let factor = (len - remainder)/10;

  let noOfCols = "col" + factor;

  if (len > 10) {
    $('#company-dropdown').addClass(noOfCols);
  }

  $("#notificationDropdown").click(function() {
    $("#notificationCount").hide();
  });
});