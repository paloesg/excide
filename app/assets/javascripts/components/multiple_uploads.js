Dropzone.autoDiscover = false;

$(document).ready(function () {
  var documentUpload = new Dropzone('#uploader', { timeout: 0 });

  documentUpload.on("success", function (file, request) {
    var resp = $.parseXML(request);
    var filePath = $(resp).find("Key").text();
    var location = new URL($(resp).find("Location").text())
    $.post('/symphony/documents', {
      authenticity_token: $.rails.csrfToken(),
      document_type: 'invoice',
      document: {
        filename: file.name,
        identifier: (new Date()).toISOString().replace(/[^\w\s]/gi, '') + '-' + file.name,
        file_url: '//' + location['host'] + '/' + filePath,
      }
    });
  });

  documentUpload.on("queuecomplete", function (file, request) {
    $('#view-invoices-button').show();
  });
});