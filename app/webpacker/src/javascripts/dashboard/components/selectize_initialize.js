$(document).on("turbolinks:before-render", function() {
  $('select.selectize')[0].selectize.destroy();
})
$(document).on("turbolinks:load", function() {
  $('select.selectize-workflow-type').selectize({
    allowEmptyOption: true,
    onItemAdd: function (value, $item) {
      Turbolinks.visit('//' + location.host + location.pathname + '?workflow_type=' + value);
    },
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $('select.selectize-year').selectize({
    allowEmptyOption: true,
    onItemAdd: function (value, $item) {
      Turbolinks.visit('//' + location.host + location.pathname + '?year=' + value);
    },
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });
  
  $('.tasks-filter-button').click(function (e) {
    var tasks_selectize = $('select.selectize-tasks').selectize();
    var created_at_selectize = $('select.selectize-created-at').selectize();
    var types_selectize = $('select.selectize-types').selectize();

    var tasksData = (tasks_selectize[0].selectize).getValue();
    var createdAtData = (created_at_selectize[0].selectize).getValue();
    var typesData = (types_selectize[0].selectize).getValue();

    Turbolinks.visit('//' + location.host + location.pathname + '?tasks=' + tasksData + '&created_at=' + createdAtData + '&types=' + typesData);
  });

  $('.activity-history-filter-button').click(function (e) {
    var created_at_selectize = $('select.selectize-created-at').selectize();
    var createdAtData = (created_at_selectize[0].selectize).getValue();
    Turbolinks.visit('//' + location.host + location.pathname + '?created_at=' + createdAtData);
  });

  if ($('#new-event.d-none')[0] == undefined) {
    $('select.selectize').selectize({
      onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
    });

    $('select.selectize-user-assignment').selectize();
  }

  $('select.project-clients').selectize({
    placeholder: "Choose project clients...",
    plugins: ['remove_button'],
    allowEmptyOption: true,
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $("select.service-line").selectize({
    placeholder: "Choose service line...",
    plugins: ['remove_button'],
    allowEmptyOption: true,
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $('select.allocation-users').selectize({
    placeholder: "Choose user...",
    plugins: ['remove_button'],
    allowEmptyOption: true,
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $('select.event-type').selectize({
    placeholder: "Choose event type",
    plugins: ['remove_button'],
    allowEmptyOption: true,
    onFocus: function () { $(".selectize-input input").attr("style", "width: auto;"); }
  });

  $("select.role-select-users").selectize({
    plugins: ['remove_button'],
    delimiter: " ",
    persist: false,
    create(input) {
      return {
        value: input,
        text: input
      };
    }
  });

  $('.conductor-filter-button').click(function (e) {
    
    var allocationUserSelectize = $("select.allocation-users").selectize();
    var eventTypeSelectize = $("select.event-type").selectize();
    var projectClientSelectize = $("select.project-clients").selectize();

    var projectClientData = (projectClientSelectize[0].selectize).getValue();
    var allocationUserData = (allocationUserSelectize[0].selectize).getValue();
    var eventTypeData = (eventTypeSelectize[0].selectize).getValue();

    Turbolinks.visit('//' + location.host + location.pathname + '?event_types=' + eventTypeData +'&project_clients='+ projectClientData +'&allocation_users='+ allocationUserData);
  });

  $(".timesheet-filter-button").click(function() {
    let startDate = $("#startDate").val();
    let endDate = $("#endDate").val();

    let projectClientSelectize = $("select.project-clients").selectize();
    let projectClientData = (projectClientSelectize[0].selectize).getValue();

    let allocationUserSelectize = $("select.allocation-users").selectize();
    let allocationUserData = (allocationUserSelectize[0].selectize).getValue();

    let serviceLineSelectize = $("select.service-line").selectize();
    let serviceLineData = (serviceLineSelectize[0].selectize).getValue();

    Turbolinks.visit('//' + location.host + location.pathname + '?start_date=' + startDate +'&end_date='+ endDate +'&project_clients='+ projectClientData + '&allocation_users=' + allocationUserData + '&service_line=' + serviceLineData);
  })

})
