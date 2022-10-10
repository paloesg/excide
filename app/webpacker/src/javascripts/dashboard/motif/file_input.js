$(document).on("turbolinks:load", function () {
  // init bootstrap popover
  $(".custom-file-input").on("change", function () {
    var fileName = $(this).val().replace(/^.*[\\\/]/, '');
    $(this)
      .next(".custom-file-label")
      .addClass("selected")
      .html(fileName);
  });
});