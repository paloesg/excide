Dropzone.autoDiscover = false;

$(document).ready(function () {
  var myDropzone = new Dropzone('#uploader', { timeout: 0 });

  myDropzone.on("success", function (file, request) {
    var resp = $.parseXML(request);
    var filePath = $(resp).find("Key").text();
    $.post('/symphony/documents', {
      authenticity_token: $.rails.csrfToken(),
      document: {
        filename: file.name,
        identifier: file.name,
        file_url: filePath,
      }
    })
  });
});