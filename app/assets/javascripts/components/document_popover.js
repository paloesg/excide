$(document).on("turbolinks:load", function() {
  $(".pdf-preview").popover({
    html : true,
    placement : "auto",
    trigger : "focus",
    sanitize : false,
    content() {
      return "<iframe src='https://docs.google.com/viewer?url=" + $(this).attr("data-document") + "&embedded=true' frameborder='0' height='600px' width='450px'></iframe>";
    }
  });
});