Dropzone.autoDiscover = false;

function uploadMultipleDocuments(data){
  $.post('/symphony/documents/multiple', {data_inputs: data})
}

function uploadDocuments(data){
  $.post('/symphony/documents', data)
}

$(document).ready(function () {
  var multiple_data = [];
  // Show dropzone after client and template selected
  $("#template_id").on('change', function() {
    if ( $("#template_id").val() ) {
      $(".multiple_uploads").collapse();
    }
  })

  //upload documents on workflows page
  if ($(".action_id").length) {
    $( ".action_id" ).each(function( index ) {
      var action_id = $(this).attr('id')
      var workflow_action_id = $('#'+action_id).val();

      if($(".uploadToXero"+workflow_action_id).length){
        var cleanFilename = function (name) {
          fileName = name.split('.').slice(0, -1).join('.')
          get_extension = name.substring(name.lastIndexOf(".") + 1)
          // Filter out special characters and spaces in filename (same as parametrize function in rails)
          filter_filename = fileName.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
          return filter_filename + '.' + get_extension;
        };
        var documentUploadToXero = new Dropzone(".uploadToXero"+workflow_action_id,{
          timeout: 0,
          renameFilename: cleanFilename,
        })
        documentUploadToXero.on("success", function(file, request){
          var resp = $.parseXML(request);
          var filePath = $(resp).find("Key").text();
          var location = new URL($(resp).find("Location").text());
          if($("#uploadToXero"+workflow_action_id).length){
            //check this part of drag and drop
            data = {
              authenticity_token: $.rails.csrfToken(),
              workflow: $('#workflow_identifier').val(),
              workflow_action: workflow_action_id,
              document: {
                filename: file.upload.filename,
                file_url: '//' + location['host'] + '/' + filePath
              }
            }
            uploadDocuments(data);
          }
        })
      }
    });
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
    Dropzone.options.documentUpload = {
      chunking: true,      // enable chunking
      forceChunking: true, // forces chunking when file.size < chunkSize
      parallelChunkUploads: false,
      chunkSize: 1000000,  // chunk size 1,000,000 bytes (~1MB)
      retryChunks: true,   // retry chunks on failure
      retryChunksLimit: 10 // retry maximum of 3 times (default is 3)
    };
    documentUpload.on("addedfile", function () {
      $('#drag-and-drop-submit').removeAttr('disabled');
    });
    $("#drag-and-drop-submit").click(function(){
      documentUpload.processQueue();
      $.post("/symphony/batches", {
        authenticity_token: $.rails.csrfToken(),
        batch: {
          template_id: $('#template_id').val(),
        }
      });
    });
    documentUpload.on("success", function (file, request) {
      var resp = $.parseXML(request);
      var filePath = $(resp).find("Key").text();
      var location = new URL($(resp).find("Location").text())
      var data_input = {
        authenticity_token: $.rails.csrfToken(),
        document_type: 'batch-uploads',
        count: this.files.length,
        workflow_identifier: (new Date()).toISOString().replace(/[^\w\s]/gi, '') + '-' + file.upload.filename,
        document: {
          filename: file.upload.filename,
          file_url: '//' + location['host'] + '/' + filePath,
          template_id: $('#template_id').val(),
        }
      }

      uploadDocuments(data_input);
      // multiple_data.push(data_input);
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
      // console.log(multiple_data)
      // uploadMultipleDocuments(multiple_data);
      $('#view-invoices-button').show();
    });
  };
});