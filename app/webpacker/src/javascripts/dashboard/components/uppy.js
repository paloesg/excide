const Uppy = require('@uppy/core');
const Dashboard = require('@uppy/dashboard');
const ActiveStorageUpload = require('@excid3/uppy-activestorage-upload');
const GoogleDrive = require('@uppy/google-drive');

require('@uppy/core/dist/style.css');
require('@uppy/dashboard/dist/style.css');

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll('[data-uppy]').forEach(element => setupUppy(element))
})
function setupUppy(element){
  let trigger = element.querySelector('[data-behavior="uppy-trigger"]')
  console.log("trigger is: ", trigger);
  let form = element.closest('form')
  console.log("form is: ", form);

  let direct_upload_url = document.querySelector("meta[name='direct-upload-url']").getAttribute("content")
  console.log("direct_upload_url is: ", direct_upload_url);

  let field_name = element.dataset.uppy
  console.log("field name: ", field_name);

  trigger.addEventListener("click", (event) => event.preventDefault())

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
    // trigger: trigger,
    id: 'Dashboard',
    theme: 'dark',
    // target: 'body',
    target: '.dashboard-body',
    note: 'Images and video only, 2–3 files, up to 1 MB',
    width: 750,
    height: 550,
    thumbnailWidth: 280,
    // After uploading done, immediately close modal
    // closeAfterFinish: true
  }).use(GoogleDrive, {
    target: Dashboard,
    companionUrl: 'https://companion.uppy.io/',
  })
  
  uppy.on('complete', (result) => {
    console.log(result)
  })
}
