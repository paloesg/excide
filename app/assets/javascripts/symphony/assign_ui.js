function assign(form_element) {
  let formJquery = $(form_element);
  let formParent = formJquery.parent();
  let tableRow = formParent.parent().parent();
  formJquery.submit();
  $(formParent).bind('turbolinks:request-end', function(evt, data, status, xhr) {
    $(tableRow.find(".fa-check")).show().fadeTo(500, 200, function () {
      $(tableRow.find(".fa-check")).fadeTo(200, 0);
    });
  });
  $(formParent).ajaxError(function(event, request, settings) {
    $(tableRow.find(".fa-times")).show().fadeTo(500, 200, function () {
      $(tableRow.find(".fa-times")).fadeTo(200, 0);
    });
  });
}