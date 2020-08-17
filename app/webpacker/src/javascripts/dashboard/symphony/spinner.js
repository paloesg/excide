$(document).on("turbolinks:load", function() {
  $(".start-loading").click(function(e){
    console.log("I am here");
    // e.preventDefault();
    $("#loading").removeClass("d-none");
    // setInterval(function(){ 
    //  $("#loading").addClass("d-none");
    // }, 3000);
    // Turbolinks.visit(window.location);
  });
});
