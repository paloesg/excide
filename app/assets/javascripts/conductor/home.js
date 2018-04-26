$(document).ready( function () {
  $('.day').popover({
    html: true,
    title: 'New activation',
    container: 'body',
    placement: 'auto left',
    content: function () {
      return $('#popover-show').html();
    }
  }).on('shown.bs.popover', function () {
    $('.datetimepicker').datetimepicker({
      format: "YYYY-MM-DD HH:mm",
      stepping: 15,
      sideBySide: true
    });
    $('.datetimepicker').val($(this).attr('td-date'));
  }).on("show.bs.popover", function () {
    $(this).data("bs.popover").tip().css("max-width", "none");
    $('.popover').popover('hide');
  });
});