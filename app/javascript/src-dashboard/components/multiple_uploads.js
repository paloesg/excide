/*global Dropzone*/
/*eslint no-undef: "error"*/
/*eslint camelcase: ["error", {allow: ["authenticity_token", "url_files"]}]*/
var linkTo = "";
function uploadDocuments(data){
  $.post("/symphony/documents", data).done((result) => {
    linkTo = result["link_to"];
    Turbolinks.visit(linkTo);
  })
}

Dropzone.autoDiscover = false;

$(document).on("turbolinks:load", function() {

  var fileName, get_extension, filter_filename;
  // Show dropzone after client and template selected
  $("#template_id").on('change', function() {
    if ( $("#template_id").val() ) {
      $(".multiple_uploads").collapse();
    }
  })

  //upload documents on workflows and batch page
  if ($(".action_id").length){
    $( ".action_id" ).each(function( index ) {
      let actionId = $(this).attr('id')
      let workflowActionId = $('#'+actionId).val();
      let actionIdStr = actionId.substr(10);

      if($(".uploadToXero"+workflowActionId).length){
        let cleanFilename = function (name) {
          fileName = name.split('.').slice(0, -1).join('.')
          get_extension = name.substring(name.lastIndexOf(".") + 1)
          // Filter out special characters and spaces in filename (same as parametrize function in rails)
          filter_filename = fileName.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
          return filter_filename + '.' + get_extension;
        };
        let documentUploadToXero = new Dropzone(".uploadToXero"+workflowActionId,{
          timeout: 0,
          renameFilename: cleanFilename,
        })
        documentUploadToXero.on("success", function(file, request){
          let resp = $.parseXML(request);
          let filePath = $(resp).find("Key").text();
          let location = new URL($(resp).find("Location").text());
          if($("#uploadToXero"+workflowActionId).length){
            //check this part of drag and drop
            let data_input = {
              authenticity_token: $.rails.csrfToken(),
              workflow: $('#workflow_id_'+actionIdStr).val(),
              workflow_action: workflowActionId,
              document: {
                filename: file.upload.filename,
                file_url: '//' + location['host'] + '/' + filePath
              }
            };
            uploadDocuments(data_input);
          }
        });
      }
    });
  }

  // $("#uploader").length 'To check #uploader is exists'
  if ($(".multiple_uploads").length) {
    $('.loading').hide();
    var batchId="";
    var cleanFilename = function (name) {
      fileName = name.split('.').slice(0, -1).join('.')
      get_extension = name.substring(name.lastIndexOf(".") + 1)
      // Filter out special characters and spaces in filename (same as parametrize function in rails)
      filter_filename = fileName.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
      return filter_filename + '.' + get_extension;
    };
    let documentUpload = new Dropzone(".multiple_uploads", {
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
    documentUpload.on("addedfile", function (file) {
      // Check if file name are same & rename the file
      if (this.files.length && $('#template_id').val()) {
        let _i, _len;
        for (_i = 0, _len = this.files.length; _i < _len - 1; _i++) {
          if (this.files[_i].name === file.name) {
            this.removeFile(file);
            fileName = file.name.split('.').slice(0, -1).join('.')
            get_extension = file.name.substring(file.name.lastIndexOf(".") + 1)
            renameFile = new File([file], fileName + '_' + btoa(Math.random()).substr(5, 5) + '.' + get_extension, { type: file.type });
            documentUpload.addFile(renameFile);
          }
        }
        //activate button submit
        $('#drag-and-drop-submit').removeAttr('disabled');
      }
    });
    // active button submit if any files on dropzone, when any template selected
    $('#template_id').change(function() {
      if (documentUpload.files.length) {
        $('#drag-and-drop-submit').removeAttr('disabled');
      }
    });
    $("#drag-and-drop-submit").click(function(){
      $.post("/symphony/batches", {
        authenticity_token: $.rails.csrfToken(),
        batch: {
          template_id: $('#template_id').val(),
        }
      }).done(result => {
        if(result.status == "ok"){
          batchId = result.batch_id;
          documentUpload.processQueue();
        }
        else {
          Turbolinks.visit('/symphony/batches/'+$('#template_id').val()+'/new');
        }
      });
    });
    documentUpload.on("queuecomplete", () => {
      // Create workflows from multiple files
      $.each(documentUpload["files"], (index, file) => {
        getUrlResponse = $.parseXML(file["xhr"]["response"]);
        $(getUrlResponse).find("Location").text();
        let data_input = {
          authenticity_token: $.rails.csrfToken(),
          document_type: 'batch-uploads',
          batch_id: batchId,
          count: documentUpload["files"].length,
          document: {
            filename: file.upload.filename,
            file_url: $(getUrlResponse).find("Location").text(),
            template_id: $('#template_id').val()
          }
        };
        let result = uploadDocuments(data_input);
      })

      let totalFile = documentUpload.files.length;
      $('#drag-and-drop-submit').prop( "disabled", true );
      $('#view-invoices-button').show();
      //if this function in create batch, redirect to show batch page after create
      if($("#batch-uploader").length){
        $('.loading').show();
        // set the timer (total file multiplied by 0.5 seconds) after create documents to redirect page
        window.setTimeout(function() {
          $('.loading').hide();
          // Turbolinks.visit(linkTo);
        }, totalFile*1000);
      }
    });
  };
});