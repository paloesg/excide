$(function () {
  $('[data-toggle="popover"]').popover();
}).on("show.bs.popover", function () {
  $('.popover').popover('hide');
});