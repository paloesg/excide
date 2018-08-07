$(document).ready(function () {
  $('select.selectize-workflow-type').selectize({
    allowEmptyOption: true,
    onItemAdd: function (value, $item) {
      Turbolinks.visit('//' + location.host + location.pathname + '?workflow_type=' + value);
    },
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $('select.selectize-activation-type').selectize({
    allowEmptyOption: true,
    onItemAdd: function (value, $item) {
      Turbolinks.visit('//' + location.host + location.pathname + '?activation_type=' + value);
    },
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $('select.selectize').selectize();
})