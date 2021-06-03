/*$(document).on("turbolinks:load", function(){
  if($('.break-inside-avoid').length > 20) {
    $('#company-dropdown').addClass("col3");
  }
  else if($('.break-inside-avoid').length > 10){
    $('#company-dropdown').addClass("col2");
  }
  $("#notificationDropdown").click(function() {
    $("#notificationCount").hide();
  });
});
*/



$(document).on("turbolinks:load", function(){
	let len = $('.break-inside-avoid').length;
	let factor = len/10;

	let noOfCols = "col" + factor;

	if (len > 10) {
	  $('#company-dropdown').addClass(noOfCols);
	}

  $("#notificationDropdown").click(function() {
    $("#notificationCount").hide();
  });
});