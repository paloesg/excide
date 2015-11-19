window.App ||= {}

App.init = ->
  mixpanel.track("Page view");

  if $('body').hasClass('index')
    $('#fullpage').fullpage({
      responsiveWidth: 992
    })
  else
    $('#fullpage').fullpage.destroy('all')

$(document).on "page:change", ->
  App.init()