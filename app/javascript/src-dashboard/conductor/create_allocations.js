var createAllocation = function(id, type, element) {
  let count = element.value
  $.ajax({
    type: "GET",
    url: "conductor/events/" + id + "/create-allocations/" + type + "/" + count,
    dataType: "json",
    success: function () {
      $(element).prop('disabled', 'disabled');
      $(element).closest("tr").find(".fa-check").fadeTo(500, 1, function () {
        $(element).closest("tr").find(".fa-check").fadeTo(2000, 0)
      })
    },
    error: function () {
      $(element).closest("tr").find(".fa-times").show().fadeTo(500, 1, function () {
        $(element).closest("tr").find(".fa-times").fadeTo(2000, 0)
      })
    }
  })
}

// webpack support
if (typeof module !== 'undefined' && typeof module.exports !== 'undefined') {
    module.exports = createAllocation;
}