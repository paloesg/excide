$(document).on("turbolinks:load", function () {
  $('.preview-click').click(function(){
    $('#document-previewer').html("<%= escape_javascript render(:partial => 'overture/shared/show_document') %>");
  });
});
