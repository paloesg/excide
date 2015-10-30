window.App ||= {}

App.init = ->
  $('#fullpage').fullpage({
    responsiveWidth: 992
  })

$(document).on "page:change", ->
  App.init()