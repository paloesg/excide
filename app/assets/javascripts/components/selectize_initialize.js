$(document).on("turbolinks:load", function() {
  $('select.selectize-workflow-type').selectize({
    allowEmptyOption: true,
    onItemAdd: function (value, $item) {
      Turbolinks.visit('//' + location.host + location.pathname + '?workflow_type=' + value);
    },
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $('select.selectize-event-type').selectize({
    allowEmptyOption: true,
    onItemAdd: function (value, $item) {
      Turbolinks.visit('//' + location.host + location.pathname + '?event_type=' + value);
    },
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  if ($('#new-event.d-none')[0] == undefined) {
    $('select.selectize').selectize({
      onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
    });
    $('select.selectize-user-assignment').selectize();
  }
})