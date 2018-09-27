function assign(form_element) {
  formJquery = $(form_element);
  formParent = formJquery.parent();
  tableRow = formParent.parent().parent();
  formJquery.submit();
  $(formParent).on('ajax:success', function () {
    $(tableRow.find(".fa-check")).show().fadeTo(500, 200, function () {
      $(tableRow.find(".fa-check")).fadeTo(200, 0);
    });
  }).on('ajax:error', function () {
    $(tableRow.find(".fa-times")).show().fadeTo(500, 200, function () {
      $(tableRow.find(".fa-times")).fadeTo(200, 0);
    });
  });
}