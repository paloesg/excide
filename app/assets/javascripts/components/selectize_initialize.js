$(document).on("turbolinks:load", function() {
  $('select.selectize-workflow-type').selectize({
    allowEmptyOption: true,
    onItemAdd: function (value, $item) {
      Turbolinks.visit('//' + location.host + location.pathname + '?workflow_type=' + value);
    },
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });
  
  if ($('#new-activation.d-none')[0] == undefined) {
    $('select.selectize').selectize({
      onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
    });
    $('select.selectize-user-assignment').selectize();
  }

  $('select.project-clients').selectize({
    placeholder: "Choose project clients",
    plugins: ['remove_button'],
    allowEmptyOption: true,
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $('select.allocation-users').selectize({
    placeholder: "Choose user allocation",
    plugins: ['remove_button'],
    allowEmptyOption: true,
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $('select.activation-type').selectize({
    placeholder: "Choose activation type",
    plugins: ['remove_button'],
    allowEmptyOption: true,
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $('.conductor-filter-button').click(function (e) {
    var project_client_selectize = $('select.project-clients').selectize();
    var allocation_user_selectize = $('select.allocation-users').selectize();
    var activation_type_selectize = $('select.activation-type').selectize();

    var projectClientData = (project_client_selectize[0].selectize).getValue();
    var allocationUserData = (allocation_user_selectize[0].selectize).getValue();
    var activationTypeData = (activation_type_selectize[0].selectize).getValue();
    
    Turbolinks.visit('//' + location.host + location.pathname + '?activation_types=' + activationTypeData +'&project_clients='+ projectClientData +'&allocation_users='+ allocationUserData);
  });

})