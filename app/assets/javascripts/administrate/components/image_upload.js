callDirectUpload()
function callDirectUpload() {
  $('.directUpload').find("input:file").each(function(i, elem) {
    var fileInput    = $(elem);
    var form         = $(fileInput.parents('form:first'));
    var submitButton = form.find('input[type="submit"]');
    var progressBar  = $("<div class='bar'></div>");
    var barContainer = $("<div class='progress'></div>").append(progressBar);
    fileInput.after(barContainer);
    fileInput.fileupload({
      fileInput:       fileInput,
      url:             form.data('url'),
      type:            'POST',
      autoUpload:       true,
      formData:         form.data('form-data'),
      paramName:        'file', // S3 does not like nested name fields i.e. name="user[avatar_url]"
      dataType:         'XML',  // S3 returns XML if success_action_status is set to 201
      replaceFileInput: false,
      add: function (e, data) {
        rawFileName = e.target.files[0].name
        fileName = rawFileName.split('.').slice(0, -1).join('.')
        get_extension = rawFileName.substring(rawFileName.lastIndexOf(".") + 1)
        // Filter out special character in filename
        filter_filename = fileName.replace(/[^\w\s]/gi, '')
        // Get s3 key url
        s3_url_key_with_filename = form.data('form-data')['key']
        // Remove default filename from s3 key url
        s3_url_key = s3_url_key_with_filename.replace(/[^\/]*$/, '')
        // The new filename with s3 key url
        form.data('form-data')['key'] = s3_url_key + filter_filename + '.' + get_extension
        data.formData = form.data('form-data')
        data.submit();
      },
      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        progressBar.css('width', progress + '%')
      },
      start: function (e) {
        submitButton.prop('disabled', true);

        progressBar.
          css('background', 'green').
          css('display', 'block').
          css('width', '0%').
          text("Loading...");
      },
      done: function(e, data) {
        submitButton.prop('disabled', false);
        progressBar.text("Uploading done");

        // extract key and generate URL from response
        var key   = $(data.jqXHR.responseXML).find("Key").text();
        var url   = '//' + form.data('host') + '/' + key;

        // create hidden field
        var input = $("<input />", { type:'hidden', name: fileInput.attr('name'), value: url })
        form.append(input);
      },
      fail: function(e, data) {
        submitButton.prop('disabled', false);

        progressBar.
          css("background", "red").
          text("Failed");
      }
    });
  });
}