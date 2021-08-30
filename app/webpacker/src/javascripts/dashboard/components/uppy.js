const Uppy = require('@uppy/core');
const Dashboard = require('@uppy/dashboard');
const ActiveStorageUpload = require('@excid3/uppy-activestorage-upload');

require('@uppy/core/dist/style.css');
require('@uppy/dashboard/dist/style.css');

//------------------------Upload to Document's create method----------------------------
function uploadDocuments(data){
  $.post("/symphony/documents", data).done((result) => {
    const linkTo = result["link_to"];
    Turbolinks.visit(linkTo);
  });
}
//---------------------Different multiple upload methods--------------------------------
const batchUploads = (uppy) => {
  // Create document upon completion of all the files upload. Loop through the document and post a request per document
  uppy.on('complete', (result) => {
    if($('.batchUploads').length){
      $.post("/symphony/batches", {
        authenticity_token: $.rails.csrfToken(),
        batch: {
          template_slug: $('#template_slug').val()
        },
        source: 'upload',
        document_type: 'batch-uploads',
        successful_results: JSON.stringify(result)
      }).done((result) => {
        const linkTo = result["link_to"];
        Turbolinks.visit(linkTo);
      });
    }
  });
};

// Multiple uploads for Symphony through document's INDEX page
const multipleDocumentsUpload = (uppy) => {
  uppy.on('complete', (result) => {
    $.post("/symphony/documents/index-create", {
      authenticity_token: $.rails.csrfToken(),
      // Number of file uploads that were uploaded successfully
      successful_files: JSON.stringify(result.successful),
      document_type: 'documents-multiple-uploads',
    });
  });
};

// Multiple uploads through workflow's task
const multipleUploadTask = (uppy) => {
  uppy.on('complete', (result) => {
    let actionId = $(".action_id").attr('id');
    let workflowActionId = $('#'+actionId).val();
    let actionIdStr = actionId.substr(10);
    result.successful.forEach((file) => {
      let data_input = {
        authenticity_token: $.rails.csrfToken(),
        workflow: $('#workflow_id_'+actionIdStr).val(),
        workflow_action: workflowActionId,
        document: {
          // have to pass in a null value to GenerateDocumentService if not will get undefined method error
          template_slug: null,
        },
        document_type: "multiple-file-upload-task",
        response_key: file.response.key
      };
      // Wait for 3 seconds before posting to document. On development, the file post too fast, that the batchId could not get captured
      let result = setTimeout(uploadDocuments(data_input), 3000);
    });
  });
};

// Multiple uploads for Motif through document's INDEX page
const motifMultipleDocumentsUpload = (uppy) => {
  uppy.on('complete', (result) => {
    $.post("/motif/documents", {
      authenticity_token: $.rails.csrfToken(),
      // Number of file uploads that were uploaded successfully
      successful_files: JSON.stringify(result.successful),
      document_type: 'motif-documents-multiple-uploads',
      folder_id: $(".motifMultipleDocumentsUpload").data("folder"),
    });
  });
};
// Motif outlet's photo gallery
const motifOutletPhotosUpload = (uppy) => {
  uppy.on('complete', (result) => {
    let outlet_id = $("#outlet_id").val()
    $.post("/motif/outlets/" + outlet_id + "/photos_upload", {
      authenticity_token: $.rails.csrfToken(),
      // Number of file uploads that were uploaded successfully
      successful_files: JSON.stringify(result.successful),
    });
  });
};

// Motif upload through task drawer
const motifWorkflowActionMultipleUploads = (uppy) => {
  uppy.on('complete', (result) => {
    const wf_id = $(".motifWorkflowActionMultipleUploads").data("workflow")
    $.post("/motif/workflows/" + wf_id + "/upload_documents", {
      authenticity_token: $.rails.csrfToken(),
      // Number of file uploads that were uploaded successfully
      successful_files: JSON.stringify(result.successful),
      wfa_id: $(".motifWorkflowActionMultipleUploads").data("wfa"),
    });
  });
};

// Multiple uploads for Overture through document's INDEX page
const overtureMultipleDocumentsUpload = (uppy) => {
  uppy.on('complete', (result) => {
    $.post("/overture/startups/documents", {
      authenticity_token: $.rails.csrfToken(),
      // Number of file uploads that were uploaded successfully
      successful_files: JSON.stringify(result.successful),
      document_type: 'overture-documents-multiple-uploads',
      folder_id: $(".overtureMultipleDocumentsUpload").data("folder"),
    });
  });
};

//-----------------------------------Setup Uppy-----------------------------------------
function setupUppy(element){
  let form = element.closest('form');
  // Get direct_upload content out of the head tag (meta tag)
  let directUploadUrl = document.querySelector("meta[name='direct-upload-url']").getAttribute("content");

  let uppy = Uppy({
    // Automatically upload file when you drop file into it
    autoProceed: false,
    allowMultipleUploads: false,
    // In case of typos
    logger: Uppy.debugLogger,
    restrictions: {
      // 100MB max size
      maxFileSize: 100 * 1024 * 1024,
      maxNumberOfFiles: 100,
      minNumberOfFiles: null,
      // Only allow images or PDF
      allowedFileTypes: ['image/*', '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', 'text/csv']
    },
    // Check if there is a template value, before uploading files
    onBeforeUpload: (files) => {
      if ($('#template_slug').val() == ""){
        alert('No template found. Please select a template and upload again!');
        return false;
      }
    }
  });

  uppy.use(ActiveStorageUpload, {
    directUploadUrl
  });

  uppy.use(Dashboard, {
    inline: true,
    id: 'Dashboard',
    theme: 'light',
    target: '.dashboard-body',
    note: 'Images and video only, 2–3 files, up to 1 MB',
    width: 570,
    height: 300,
    thumbnailWidth: 280,
    metaFields: [
      { id: 'name', name: 'Name', placeholder: 'file name' }
    ]
  });

  if($('.batchUploads').length){
    batchUploads(uppy);
  }
  else if($('.documentMultipleUploads').length){
    multipleDocumentsUpload(uppy);
  }
  else if($('.multipleUploadsTask').length){
    multipleUploadTask(uppy);
  }
  else if($('.motifMultipleDocumentsUpload').length){
    motifMultipleDocumentsUpload(uppy);
  }
  else if($('.motifOutletPhotosUpload').length){
    motifOutletPhotosUpload(uppy);
  }
  else if($('.motifWorkflowActionMultipleUploads').length){
    motifWorkflowActionMultipleUploads(uppy);
  }
  else if ($(".overtureMultipleDocumentsUpload").length) {
    overtureMultipleDocumentsUpload(uppy);
  }
}
//-----------------------------------Initialize Uppy------------------------------------
document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll('.dashboard-body').forEach((element) => setupUppy(element));
});
