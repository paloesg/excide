$(document).on("turbolinks:load", function() {
  $('.pdf-preview').popover({
    html : true,
    placement : "auto",
    trigger : "focus",
    content: function() {
      return '<strong class="document-content">Loading...</strong>';
      }
  }).on('inserted.bs.popover',function(){
    $($(this).data("bs.popover").tip).find('.document-content').replaceWith('<iframe src="https://docs.google.com/viewer?url=' + $(this).attr('data-document') + '&embedded=true" frameborder="0" height="300px" width="250px"></iframe>')
  });
});