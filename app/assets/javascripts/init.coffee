window.App ||= {}

App.init = ->
  $('#fullpage').fullpage({
    responsiveWidth: 992
  })
  mixpanel.track("Page view");

$(document).on "page:change", ->
  App.init()