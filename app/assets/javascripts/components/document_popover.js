$(document).on("turbolinks:load", function() {
  console.log("document preview loaded script")
  $('.document-preview').popover({
    html : true,
    placement : "auto",
    content: function() {
      console.log("test")
      return '<iframe src="https://docs.google.com/viewer?url=http://www.pdf995.com/samples/pdf.pdf&embedded=true" frameborder="0" height="300px" width="250px">'+
        '</iframe>';
      }
   });
});