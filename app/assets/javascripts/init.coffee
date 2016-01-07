window.App ||= {}

App.init = ->
  mixpanel.track("Page view");

  if $('body').hasClass('index')
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

$(document).on "page:change", ->
  App.init()