$(function () {
  $('[data-toggle="popover"]').popover();
  $('.pop').popover().click(function () {
    setTimeout(function () {
        $('.pop').popover('hide');
    }, 2000);
});
})
