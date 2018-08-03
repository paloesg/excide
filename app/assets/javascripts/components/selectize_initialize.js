$(document).ready(function () {
  $('select.selectize').selectize({
    allowEmptyOption: true,
    sortField: { field: '$score' }
  });
})