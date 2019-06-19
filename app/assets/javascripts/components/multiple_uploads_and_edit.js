Dropzone.autoDiscover = false;

$(document).ready(function () {

  // Multiple uploads on document index page
  if ($(".multiple_uploads_and_edit").length) {
    var cleanFilename = function (name) {
      fileName = name.split('.').slice(0, -1).join('.')
      get_extension = name.substring(name.lastIndexOf(".") + 1)
      // Filter out special characters and spaces in filename (same as parametrize function in rails)
      filter_filename = fileName.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
      return filter_filename + '.' + get_extension;
    };

    var documentUpload = new Dropzone('.multiple_uploads_and_edit', { timeout: 0, renameFilename: cleanFilename });

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
      // Get url files after uploaded
      var url_files = []
      $.each(this.files, function(index, value) {
        var key     = $(value.xhr.responseXML).find("Key").text();
        var parser  = document.createElement('a');
        parser.href = $(value.xhr.responseXML).find("Location").text()
        var url     = '//' + parser.hostname + '/' + key;
        url_files.push(url)
      });
      $.post('/symphony/documents/index-create', {
        authenticity_token: $.rails.csrfToken(),
        url_files: url_files
      });
    });
  };
});