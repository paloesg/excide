const Uppy = require('@uppy/core');
const Dashboard = require('@uppy/dashboard');
const ActiveStorageUpload = require('@excid3/uppy-activestorage-upload');

require('@uppy/core/dist/style.css');
require('@uppy/dashboard/dist/style.css');

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll('.dashboard-body').forEach(element => setupUppy(element))
})

function uploadDocuments(data){
  $.post("/symphony/documents", data).done((result) => {
    linkTo = result["link_to"];
    Turbolinks.visit(linkTo);
  })
}

function setupUppy(element){
  let form = element.closest('form')
  // Get direct_upload content out of the head tag (meta tag)
  let direct_upload_url = document.querySelector("meta[name='direct-upload-url']").getAttribute("content")
  // data-uppy="document[raw_file]" from form
  let field_name = element.dataset.uppy

  // trigger.addEventListener("click", (event) => event.preventDefault())

  let uppy = Uppy({
    // Automatically upload file when you drop file into it
    autoProceed: false,
    allowMultipleUploads: false,
    // In case of typos
    logger: Uppy.debugLogger
  });

  uppy.use(ActiveStorageUpload, {
    directUploadUrl: direct_upload_url
  })

  uppy.use(Dashboard, {
    inline: true,
    id: 'Dashboard',
    theme: 'dark',
    target: '.dashboard-body',
    note: 'Images and video only, 2–3 files, up to 1 MB',
    width: 570,
    height: 300,
    thumbnailWidth: 280,
    metaFields: [
      { id: 'name', name: 'Name', placeholder: 'file name' }
    ]
  })

  if($('.batchUploads').length){
    batchUploads(uppy);
  }
  else if ($('.documentMultipleUploads').length){
    multipleDocumentsUpload(uppy);
  }  
}

const batchUploads = uppy => {
  uppy.on('upload', (data) => {
    // Create batch when file(s) are starting to be uploaded
    console.log("data when initially uploading: ", data);
    if ($('#template_slug').val()){
      $.post("/symphony/batches", {
        authenticity_token: $.rails.csrfToken(),
        batch: {
          template_slug: $('#template_slug').val(),
        }
      }).done(result => {
        console.log("Result = ", result);
        if(result.status == "ok"){
          batchId = result.batch_id;
        }
        else {
          Turbolinks.visit('/symphony/batches/'+$('#template_slug').val()+'/new');
        }
      })
    }
  })
  // Create document upon completion of all the files upload. Loop through the document and post a request per document
  uppy.on('complete', (result) => {
    console.log(result);
    result.successful.forEach(file => {
      console.log("result successful file", file);
      let data_input = {
        authenticity_token: $.rails.csrfToken(),
        document_type: 'batch-uploads',
        batch_id: batchId,
        document: {
          template_slug: $('#template_slug').val()
        },
        response_key: file.response.key
      };
      // Wait for 3 seconds before posting to document. On development, the file post too fast, that the batchId could not get captured
      let result = uploadDocuments(data_input);
    })
  })
}

const multipleDocumentsUpload = uppy => {
  uppy.on('complete', (result) => {
    console.log("result is : ", result);
    $.post("/symphony/documents/index-create", {
      authenticity_token: $.rails.csrfToken(),
      // Number of file uploads that were uploaded successfully
      successful_files: JSON.stringify(result.successful),
      document_type: 'documents-multiple-uploads'
    });
  })
}
