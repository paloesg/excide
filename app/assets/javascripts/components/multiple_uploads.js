Dropzone.autoDiscover = false;

$(document).ready(function () {
  var myDropzone = new Dropzone('#uploader', { timeout: 0 });

  myDropzone.on("success", function (file, request) {
    var resp = $.parseXML(request);
    var filePath = $(resp).find("Key").text();
    var location = new URL($(resp).find("Location").text())
    $.post('/symphony/documents', {
      authenticity_token: $.rails.csrfToken(),
      document: {
        filename: file.name,
        identifier: file.name,
        file_url: '//' + location['host'] + '/' + filePath,
      }
    })
  });
});