window.assign = function(form_element) {
  let formJquery = $(form_element);
  let formParent = formJquery.parent();
  let tableRow = formParent.parent().parent();
  $.ajax({
    type: 'PATCH',
    url: '/symphony/workflow_actions/update/' + formJquery.data('action-id'),
    data: formJquery,
    dataType: 'JSON'
  }).done(function (data) {
      $(tableRow.find(".fa-check")).show().fadeTo(500, 200, function () {
        $(tableRow.find(".fa-check")).fadeTo(200, 0);
      });
  }).fail(function (data) {
      $(tableRow.find(".fa-times")).show().fadeTo(500, 200, function () {
        $(tableRow.find(".fa-times")).fadeTo(200, 0);
      });
  });
};
