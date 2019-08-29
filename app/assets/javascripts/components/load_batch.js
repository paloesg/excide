
$(document).on("turbolinks:load", function() {
  var start_from = 0;
  var limit = 10;

  $.post("/symphony/batches/load_batch/"+ start_from + "/" + limit, function(data) {
    console.log(data);
  });
})