$(function () {
  $('[data-toggle="popover"]').popover({ html: true });
}).on("show.bs.popover", function () {
  $('.popover').popover('hide');
});