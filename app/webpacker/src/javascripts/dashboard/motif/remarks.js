// For document repository offcanvas
window.remarks = function(formElement) {
  let formJquery = $(formElement);
  let tableRow = formJquery.parent().parent();
  $.ajax({
    type: "PATCH",
    url: formJquery.data("path") + formJquery.data("document-id"),
    data: formJquery,
    dataType: "JSON"
  }).done(function(data){
    // If success request, it will change the underline of the form to green color for a short while before changing back to normal line
    formJquery.css({ "border-bottom": "1px solid #B8CD59"})
    setTimeout(function(){
      formJquery.css({ "border-bottom": "1px solid #B5B5C3"})
    }, 3000);
  }).fail(function(data) {
    // If fail, it will be red
    formJquery.css({ "border-bottom": "1px solid red"})
    setTimeout(function(){
      formJquery.css({ "border-bottom": "1px solid #B5B5C3"})
    }, 3000);
  })
};
