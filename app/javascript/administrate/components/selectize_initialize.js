function callSelectize() {
  $('select').selectize({
    sortField: 'text'
  });
}

$(document).on("turbolinks:load", function() {
  callSelectize();
  $('form').on('cocoon:after-insert', function(e, inserted_item) {
    callSelectize();
    console.log(added_task);
  });
});