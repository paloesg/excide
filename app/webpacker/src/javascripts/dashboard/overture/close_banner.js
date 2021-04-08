$(document).on("turbolinks:load", function () {
  // Hide the onboarding banner when clicked close button
  $(".button-top-right").click(function(){
    $(this).closest(".card").hide();
  });
});
