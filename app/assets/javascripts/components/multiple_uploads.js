Dropzone.autoDiscover = false;

$(document).ready(function () {
  // Show dropzone after client and template selected
  $("#client_id,#template_id").on('change', function() {
    if ($("#client_id").val() && $("#template_id").val()) {
      $("#uploader").collapse();
    }
  })

  // $("#uploader").length 'To check #uploader is exists'
  if ($("#uploader").length) {
    var cleanFilename = function (name) {
      fileName = name.split('.').slice(0, -1).join('.')
      get_extension = name.substring(name.lastIndexOf(".") + 1)
      // Filter out special characters and spaces in filename (same as parametrize function in rails)
      filter_filename = fileName.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
      return filter_filename + '.' + get_extension;
    };
    var documentUpload = new Dropzone('#uploader', { timeout: 0, renameFile: cleanFilename });
    documentUpload.on("sending", function(file) {
      if ($('#client_id').val() == "" || $('#template_id').val() == "") {
        alert('Client and Template is required.');
        this.removeFile(file);
      }
    })
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
    // Check if file name are same & rename the file
    documentUpload.on("addedfile", function (file) {
      if (this.files.length) {
        var _i, _len;
        for (_i = 0, _len = this.files.length; _i < _len - 1; _i++) {
          if (this.files[_i].name === file.name) {
            this.removeFile(file);
            fileName = file.name.split('.').slice(0, -1).join('.')
            get_extension = file.name.substring(file.name.lastIndexOf(".") + 1)
            renameFile = new File([file], fileName + '_' + btoa(Math.random()).substr(5, 5) + '.' + get_extension, { type: file.type });
            documentUpload.addFile(renameFile);
          }
        }
      }
    });
    documentUpload.on("queuecomplete", function (file, request) {
      $('#view-invoices-button').show();
    });
  };
});