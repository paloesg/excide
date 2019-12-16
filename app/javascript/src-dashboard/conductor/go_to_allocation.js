$(document).on("turbolinks:load", function(){
  $("tr[data-allocation]").click(function() {
    url = new URL(location)
    params =  new URLSearchParams(url.search.slice(1))
    params.set('allocation', $(this).data('allocation'))
    Turbolinks.visit('//' + location.host + location.pathname + '?' + params);
  })
});

