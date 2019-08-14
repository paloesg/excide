$(document).on("turbolinks:load", function() {
  $('.pdf-preview').popover({
    html : true,
    placement : "auto",
    content: function() {
      return 'Loading...';
      }
   }).on('shown.bs.popover',function(){
    $($(this).data("bs.popover").tip).find('.popover-body').replaceWith('<iframe src="https://docs.google.com/viewer?url=' + $(this).attr('data-document') + '&embedded=true" frameborder="0" height="300px" width="250px"></iframe>')
 });
});