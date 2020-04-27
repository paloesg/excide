function callSelectize() {
  $('select').selectize({
    sortField: 'text'
  });
}

$(document).on("turbolinks:load", function() {
  callSelectize();
  // Render selectize when form get value in select option
  $('form').on('cocoon:after-insert', function(e, insertedItem) {
    callSelectize();
  });
});