window.App ||= {}

App.init = ->
  $('.directUpload').find('input:file').each (i, elem) ->
    fileInput = $(elem)
    form = $(fileInput.parents('form:first'))
    submitButton = form.find('input[type="submit"]')
    progressBar = $('<div class=\'progress-bar progress-bar-striped bg-success\'></div>')
    barContainer = $('<div class=\'progress mt-3\'></div>').append(progressBar)
    fileInput.after barContainer
    fileInput.fileupload
      fileInput: fileInput
      url: form.data('url')
      type: 'POST'
      autoUpload: true
      formData: form.data('form-data')
      paramName: 'file'
      dataType: 'XML'
      replaceFileInput: false
      add: (e, data) ->
        rawFileName = e.target.files[0].name
        fileName = rawFileName.split('.').slice(0, -1).join('.')
        get_extension = rawFileName.substring(rawFileName.lastIndexOf(".")+1)
        # Filter out special character in filename
        filter_filename = fileName.replace(/[^\w\s]/gi, '')
        # Get s3 key url
        s3_url_key_with_filename = form.data('form-data')['key']
        # Remove default filename from s3 key url
        s3_url_key = s3_url_key_with_filename.replace(/[^\/]*$/, '')
        # The new filename with s3 key url
        form.data('form-data')['key'] = s3_url_key + filter_filename + '.' + get_extension
        data.formData = form.data('form-data')
        data.submit();
      progressall: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        progressBar.css 'width', progress + '%'
        return
      start: (e) ->
        submitButton.prop 'disabled', true
        barContainer.css('display', 'block')
        return
      done: (e, data) ->
        submitButton.prop 'disabled', false
        progressBar.text 'File uploaded'
        # extract key and generate URL from response
        key = $(data.jqXHR.responseXML).find('Key').text()
        url = '//' + form.data('host') + '/' + key
        # create hidden field
        input = $('<input />',
          type: 'hidden'
          name: fileInput.attr('name')
          value: url)
        form.append input
        return
      fail: (e, data) ->
        submitButton.prop 'disabled', false
        progressBar.css('background', 'red').text 'Failed'
        return
    return
  return

$(document).on 'ready page:load', ->
  mixpanel.track("Page view")
  App.init()