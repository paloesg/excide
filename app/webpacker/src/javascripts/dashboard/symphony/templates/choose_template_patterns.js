$(document).on("turbolinks:load", function () {
  $(".select2-template-pattern").on("select2:select", function (e) {
    var data = e.params.data;
    if (data.text === "On demand") {
      $(".template-date-range").addClass("d-none");
      $(".template-date-range").find("input").attr("disabled", true);
    } else {
      $(".template-date-range").removeClass("d-none");
      $(".template-date-range").find("input").attr("disabled", false);
    }
  });

  $(".select2-clone-pattern").on("select2:select", function (e) {
    var data = e.params.data;
    if (data.text === "On demand") {
      $(".clone-date-range").addClass("d-none");
      $(".clone-date-range").find("input").attr("disabled", true);
    } else {
      $(".clone-date-range").removeClass("d-none");
      $(".clone-date-range").find("input").attr("disabled", false);
    }
  });
});
