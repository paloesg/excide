callSelectize()
function callSelectize() {
  $('select').selectize({
    sortField: 'text'
  });
  // Initialize selectize when add fields (nested fields)
  $(document).on('click', '.add_fields', function () {
    callSelectize();
  });
}