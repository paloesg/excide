$(document).on("turbolinks:load", function () {
  // Hide the onboarding banner when clicked close button
  $(".button-top-right").click(function(){
    $(this).closest(".card").addClass('d-none');
  });

  $(".open-banner").click(function(){
    console.log("What is this: ", $(this));
    console.log("What is this parents: ", $(this).closest(".row").prev());
    $(this).closest(".row").prev().removeClass('d-none');
  })
});
