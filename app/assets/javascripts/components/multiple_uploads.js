Dropzone.autoDiscover = false;

$(document).ready(function () {
  // Show dropzone after client and template selected
  $("#template_id").on('change', function() {
    if ( $("#template_id").val() ) {
      $(".multiple_uploads").collapse();
    }
  })

  // $("#uploader").length 'To check #uploader is exists'
  if ($(".multiple_uploads").length) {
    var cleanFilename = function (name) {
      fileName = name.split('.').slice(0, -1).join('.')
      get_extension = name.substring(name.lastIndexOf(".") + 1)
      // Filter out special characters and spaces in filename (same as parametrize function in rails)
      filter_filename = fileName.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
      return filter_filename + '.' + get_extension;
    };
    var documentUpload = new Dropzone('.multiple_uploads', { timeout: 0, renameFilename: cleanFilename });
    documentUpload.on("sending", function(file) {
      if ($("#documentIndex")) {
        if ( $('#template_id').val() == "" ) {
          alert('Template is required.');
          this.removeFile(file);
        }
      }
    })
    documentUpload.on("success", function (file, request) {
      var resp = $.parseXML(request);
      var filePath = $(resp).find("Key").text();
      var location = new URL($(resp).find("Location").text())
      if ($("#uploader").length){
        $.post('/symphony/documents', {
          authenticity_token: $.rails.csrfToken(),
          document_type: 'invoice',
          count: this.files.length,
          workflow_identifier: (new Date()).toISOString().replace(/[^\w\s]/gi, '') + '-' + file.upload.filename,
          document: {
            filename: file.upload.filename,
            file_url: '//' + location['host'] + '/' + filePath,
            template_id: $('#template_id').val(),
          }
        });
      }
      else if($("#uploadToXero").length){
        $.post('/symphony/documents', {
          authenticity_token: $.rails.csrfToken(),
          workflow: $('#workflow_identifier').val(),
          workflow_identifier: (new Date()).toISOString().replace(/[^\w\s]/gi, '') + '-' + file.upload.filename,
          document: {
            filename: file.upload.filename,
            file_url: '//' + location['host'] + '/' + filePath
          }
        });
      }
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

      // Get url images after uploaded
      var images = []
      if ($("#documentIndex")) {
        $.each(this.files, function(index, value) {
          var key     = $(value.xhr.responseXML).find("Key").text();
          var parser  = document.createElement('a');
          parser.href = $(value.xhr.responseXML).find("Location").text()
          var url     = '//' + parser.hostname + '/' + key;
          images.push(url)
        });
      }
      console.log(images)
    });
  };
});