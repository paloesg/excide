$(document).on("turbolinks:load", function() {
	// Check for the class "first-reload" to trigger the loading spinner
	// Afterwards, redirect to the same URL but without the params
	if ($("div#loading").hasClass('first-reload')) {
		$("#loading").removeClass("d-none");
		setTimeout(function(){ 
		  $("#loading").addClass("d-none");
		  // Refresh the page
		  Turbolinks.visit(window.location.href.split('?')[0])
		}, 6000);
	} 
});
