window.App ||= {}

App.init = ->
  mixpanel.track("Page view");

  if $('body').hasClass('home') && $('body').hasClass('index')
    $('#fullpage').fullpage({
      responsiveWidth: 992
    })
  else if $.isFunction($('#fullpage').fullpage.destroy)
    $('#fullpage').fullpage.destroy('all')

  $(".button-collapse").sideNav({
    edge: 'right'
  })

  if ($('body').hasClass('business') && $('body').hasClass('edit')) || $('body').hasClass('projects')
    $('select').material_select();

  if ($('body').hasClass('profiles') && $('body').hasClass('edit')) || ($('body').hasClass('business') && $('body').hasClass('edit'))
    $ ->
      $('.directUpload').find('input:file').each (i, elem) ->
        fileInput = $(elem)
        form = $(fileInput.parents('form:first'))
        submitButton = form.find('input[type="submit"]')
        progressBar = $('<div class=\'bar\'></div>')
        barContainer = $('<div class=\'progress\'></div>').append(progressBar)
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
          progressall: (e, data) ->
            progress = parseInt(data.loaded / data.total * 100, 10)
            progressBar.css 'width', progress + '%'
            return
          start: (e) ->
            submitButton.prop 'disabled', true
            progressBar.css('background', 'green').css('display', 'block').css('width', '0%').text 'Loading...'
            return
          done: (e, data) ->
            submitButton.prop 'disabled', false
            progressBar.text 'Uploading done'
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

$(document).on "page:change", ->
  App.init()