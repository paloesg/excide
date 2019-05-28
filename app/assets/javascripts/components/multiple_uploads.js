Dropzone.autoDiscover = false;

$(document).ready(function () {
  // Show dropzone after client and template selected
  $("#template_id").on('change', function() {
    if ( $("#template_id").val() ) {
      $(".multiple_uploads").collapse();
    }
  })

  if($(".uploadToXero").length){
    var cleanFilename = function (name) {
      fileName = name.split('.').slice(0, -1).join('.')
      get_extension = name.substring(name.lastIndexOf(".") + 1)
      // Filter out special characters and spaces in filename (same as parametrize function in rails)
      filter_filename = fileName.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
      return filter_filename + '.' + get_extension;
    };
    var documentUploadToXero = new Dropzone(".uploadToXero",{
      timeout: 0,
      renameFilename: cleanFilename,
    })
    documentUploadToXero.on("success", function(file, request){
      var resp = $.parseXML(request);
      var filePath = $(resp).find("Key").text();
      var location = new URL($(resp).find("Location").text());
      if($("#uploadToXero").length){
        //check this part of drag and drop
        $.post('/symphony/documents', {
          authenticity_token: $.rails.csrfToken(),
          workflow: $('#workflow_id').val(),
          document: {
            filename: file.upload.filename,
            file_url: '//' + location['host'] + '/' + filePath
          }
        });
      }
    })
  }

  // $("#uploader").length 'To check #uploader is exists'
  if ($(".multiple_uploads").length) {
    var cleanFilename = function (name) {
      fileName = name.split('.').slice(0, -1).join('.')
      get_extension = name.substring(name.lastIndexOf(".") + 1)
      // Filter out special characters and spaces in filename (same as parametrize function in rails)
      filter_filename = fileName.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
      return filter_filename + '.' + get_extension;
    };
    var documentUpload = new Dropzone(".multiple_uploads", {
      timeout: 0,
      renameFilename: cleanFilename,
      autoProcessQueue: false,
      parallelUploads: 100,
      uploadMultiple: false,
    });
    $("#drag-and-drop-submit").click(function(){
      documentUpload.processQueue();
      $.post("/symphony/batches", {
        authenticity_token: $.rails.csrfToken(),
        batch: {
          template_id: $('#template_id').val(),
        }
      });
    })
    documentUpload.on("success", function (file, request) {
      var resp = $.parseXML(request);
      var filePath = $(resp).find("Key").text();
      var location = new URL($(resp).find("Location").text())
      if($("#batch-uploader").length){
        $.post('/symphony/documents', {
          authenticity_token: $.rails.csrfToken(),
          document_type: 'batch-uploads',
          count: this.files.length,
          document: {
            filename: file.upload.filename,
            file_url: '//' + location['host'] + '/' + filePath,
            template_id: $('#template_id').val(),
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
    });
  };
});