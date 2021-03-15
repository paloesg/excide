window.contactStatusUpdate = function(formElement) {
  let formJquery = $(formElement);
  let tableRow = formJquery.parent().parent();
  console.log("What is formjquery: ", formJquery);
  console.log("What is tablerow: ", tableRow);
  $.ajax({
    type: "PATCH",
    url: "/overture/contact_statuses/" + formJquery.data("cs-id"),
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
