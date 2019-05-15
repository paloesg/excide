$(function () {
  // Popover for batch processing for multiple uploads; Popover will show instructions and roles of the tasks
  $('[data-toggle="popover"]').popover();
  $('.pop').popover().click(function () {
    setTimeout(function () {
        $('.pop').popover('hide');
    }, 5000);
  });
});