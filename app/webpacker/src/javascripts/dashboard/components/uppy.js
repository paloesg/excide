const Uppy = require('@uppy/core');
const Dashboard = require('@uppy/dashboard');
const ActiveStorageUpload = require('@excid3/uppy-activestorage-upload')

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
		autoProceed: true,
		allowMultipleUploads: false,
		// In case of typos
		logger: Uppy.debugLogger
	});

	uppy.use(ActiveStorageUpload, {
		directUploadUrl: direct_upload_url
	})

	uppy.use(Dashboard, {
		inline: true,
		trigger: trigger,
		note: 'Images and video only, 2–3 files, up to 1 MB',
		// After uploading done, immediately close modal
		// closeAfterFinish: true
	})

	uppy.on('complete', (result) => {
		console.log(result)
	})
}
