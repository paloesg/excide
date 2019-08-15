$(document).on("turbolinks:load", function() {
  $('.pdf-preview').popover({
    html : true,
    placement : "auto",
    trigger : "focus",
    sanitize : false,
    content: function() {
      return '<iframe src="https://docs.google.com/viewer?url=' + $(this).attr('data-document') + '&embedded=true" frameborder="0" height="300px" width="250px"></iframe>';
      }
  });
});