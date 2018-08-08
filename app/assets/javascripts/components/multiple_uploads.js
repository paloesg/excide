Dropzone.autoDiscover = false;

$(document).ready(function () {
  // $("#uploader").length 'To check #uploader is exists'
  if ($("#uploader").length) {
    var cleanFilename = function (name) {
      fileName = name.split('.').slice(0, -1).join('.')
      get_extension = name.substring(name.lastIndexOf(".") + 1)
      // Filter out special character in filename
      filter_filename = fileName.replace(/[^\w\s]/gi, '')
      return filter_filename + '.' + get_extension;
    };
    var documentUpload = new Dropzone('#uploader', { timeout: 0, renameFilename: cleanFilename });
    documentUpload.on("success", function (file, request) {
      var resp = $.parseXML(request);
      var filePath = $(resp).find("Key").text();
      var location = new URL($(resp).find("Location").text())
      $.post('/symphony/documents', {
        authenticity_token: $.rails.csrfToken(),
        document_type: 'invoice',
        document: {
          filename: file.upload.filename,
          identifier: (new Date()).toISOString().replace(/[^\w\s]/gi, '') + '-' + file.upload.filename,
          file_url: '//' + location['host'] + '/' + filePath,
          client_id: $('#client_id').val(),
          template_id: $('#template_id').val(),
        }
      });
    });
    documentUpload.on("queuecomplete", function (file, request) {
      $('#view-invoices-button').show();
    });
  };
});