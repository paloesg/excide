var deleteBatch = function(template, id){
  if (confirm("Are you sure you want to delete this batch and all its data?")) {
    $(".loading").show();
    $.ajax({
      url: "symphony/batches/"+ template +"/"+ id,
      type: "DELETE",
      success(result) {
        $(".loading").hide();
      }
    });
  }
}

// webpack support
if (typeof module !== 'undefined' && typeof module.exports !== 'undefined') {
  module.exports = deleteBatch;
}