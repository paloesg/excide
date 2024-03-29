$(document).on("turbolinks:load", function(){
  if ($('.directUpload').length) {
    $('.directUpload').find('input:file').each(function(i, elem) {
      let barContainer, fileInput, form, progressBar, submitButton;
      fileInput = $(elem);
      form = $(fileInput.parents('form:first'));
      submitButton = form.find('input[type="submit"]');
      progressBar = $('<div class=\'progress-bar progress-bar-striped bg-success\'></div>');
      barContainer = $('<div class=\'progress mt-3\'></div>').append(progressBar);
      fileInput.after(barContainer);
      fileInput.fileupload({
        fileInput: fileInput,
        url: form.data('url'),
        type: 'POST',
        autoUpload: true,
        formData: form.data('form-data'),
        paramName: 'file',
        dataType: 'XML',
        replaceFileInput: false,
        add: function(e, data) {
          let fileName, filterFilename, getExtension, rawFileName, s3UrlKey, s3UrlKeyWithFilename;
          rawFileName = e.target.files[0].name;
          fileName = rawFileName.split('.').slice(0, -1).join('.');
          getExtension = rawFileName.substring(rawFileName.lastIndexOf(".") + 1);
          //Filter out special characters and spaces in filename (same as parametrize function in rails)
          filterFilename = fileName.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
          //Get s3 key url
          s3UrlKeyWithFilename = form.data('form-data')['key'];
          //Remove default filename from s3 key url
          s3UrlKey = s3UrlKeyWithFilename.replace(/[^\/]*$/, '');
          //The new filename with s3 key url
          form.data('form-data')['key'] = s3UrlKey + filterFilename + '.' + getExtension;
          data.formData = form.data('form-data');
          return data.submit();
        },
        progressall: function(e, data) {
          let progress;
          progress = parseInt(data.loaded / data.total * 100, 10);
          progressBar.css('width', progress + '%');
        },
        start: function(e) {
          submitButton.prop('disabled', true);
          barContainer.css('display', 'block');
        },
        done: function(e, data) {
          let input, key, url;
          submitButton.prop('disabled', false);
          progressBar.text('File uploaded');
          //extract key and generate URL from response
          key = $(data.jqXHR.responseXML).find('Key').text();
          url = '//' + form.data('host') + '/' + key;
          //create hidden field
          input = $('<input />', {
            type: 'hidden',
            name: fileInput.attr('name'),
            value: url
          });
          form.append(input);
        },
        fail: function(e, data) {
          submitButton.prop('disabled', false);
          progressBar.css('background', 'red').text('Failed');
        }
      });
    });
  }
});
