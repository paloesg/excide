callSelectize()
function callSelectize() {
  $('select').selectize({
    sortField: 'text'
  });
}
// Initialize selectize after add fields (nested fields)
$(document).on('cocoon:after-insert', function (e, insertedItem) {
  callSelectize()
});