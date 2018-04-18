function create_allocations(id, type, element) {
  count = element.value
  $.ajax({
    type: "GET",
    url: "activations/" + id + "/create-allocations/" + type + "/" + count,
    dataType: "json",
    success: function () {
      $(element).prop('disabled', 'disabled');
      $(element).closest("tr").find(".glyphicon-ok").fadeTo(500, 1, function () {
        $(element).closest("tr").find(".glyphicon-ok").fadeTo(2000, 0)
      })
    },
    error: function () {
      $(element).closest("tr").find(".glyphicon-remove").show().fadeTo(500, 1, function () {
        $(element).closest("tr").find(".glyphicon-remove").fadeTo(2000, 0)
      })
    }
  })
}