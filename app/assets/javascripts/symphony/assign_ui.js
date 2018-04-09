function assign(form_element) {
  formJquery = $(form_element);
  formParent = formJquery.parent();
  tableRow = formParent.parent().parent();
  formJquery.submit();
  $(formParent).on('ajax:success', function () {
    $(tableRow.find(".glyphicon-ok")).show().fadeTo(500, 200, function () {
      $(tableRow.find(".glyphicon-ok")).fadeTo(200, 0);
    });
  }).on('ajax:error', function () {
    $(tableRow.find(".glyphicon-remove")).show().fadeTo(500, 200, function () {
      $(tableRow.find(".glyphicon-remove")).fadeTo(200, 0);
    });
  });
}