$(document).ready(function () {
  $('select.selectize-workflow-type').selectize({
    allowEmptyOption: true,
    sortField: { field: '$score' },
    onItemAdd: function (value, $item) {
      Turbolinks.visit('//' + location.host + location.pathname + '?workflow_type=' + value);
    }
  });

  $('select.selectize-activation-type').selectize({
    allowEmptyOption: true,
    sortField: { field: '$score' },
    onItemAdd: function (value, $item) {
      Turbolinks.visit('//' + location.host + location.pathname + '?activation_type=' + value);
    }
  });

  $('select.selectize').selectize({
    allowEmptyOption: true,
    sortField: { field: '$score' }
  });
})