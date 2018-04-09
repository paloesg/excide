function create_allocations(id, element) {
  count = element.value
  glyphicon_table_data = $(element).parent().next()
  $.ajax({
    type: "GET",
    url: "activations/" + id + "/create-allocations/" + count,
    dataType: "json",
    success: function () {
      $(element).prop('disabled', 'disabled');
      $(glyphicon_table_data.find(".glyphicon-ok")).show().fadeTo(500, 200, function () {
        $(glyphicon_table_data.find(".glyphicon-ok")).fadeTo(200, 0)
      })
    },
    error: function () {
      $(glyphicon_table_data.find(".glyphicon-remove")).show().fadeTo(500, 200, function () {
        $(glyphicon_table_data.find(".glyphicon-remove")).fadeTo(200, 0)
      })
    }
  })
}