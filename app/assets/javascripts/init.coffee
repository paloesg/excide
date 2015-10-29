window.App ||= {}

App.init = ->
  $('#fullpage').fullpage({
  })

$(document).on "page:change", ->
  App.init()