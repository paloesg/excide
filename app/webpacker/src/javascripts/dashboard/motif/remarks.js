// For dataroom offcanvas
window.remarks = function(formElement) {
  let formJquery = $(formElement);
  let tableRow = formJquery.parent().parent();
  $.ajax({
    type: "PATCH",
    url: "/motif/documents/" + formJquery.data("document-id"),
    data: formJquery,
    dataType: "JSON"
  }).done(function(data){
    $(tableRow.find(".fa-check")).show().fadeTo(500, 200, function () {
      $(tableRow.find(".fa-check")).fadeTo(200, 0);
    });
  }).fail(function (data) {
    $(tableRow.find(".fa-times")).show().fadeTo(500, 200, function () {
      $(tableRow.find(".fa-times")).fadeTo(200, 0);
    });
  });
};
