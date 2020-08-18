$(document).on("turbolinks:load", function() {
  $(".start-loading").click(function(e){
    console.log("I am here");
    $("#loading").removeClass("d-none");
    setInterval(function(){ 
     $("#loading").addClass("d-none");
    }, 5000);
  });
});
