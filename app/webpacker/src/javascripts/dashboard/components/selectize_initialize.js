$(document).on("turbolinks:before-render", function () {
  $("select.selectize")[0].selectize.destroy();
});
$(document).on("turbolinks:load", function () {
  $("select.selectize-workflow-type").selectize({
    allowEmptyOption: true,
    onItemAdd: function (value, $item) {
      Turbolinks.visit(
        "//" + location.host + location.pathname + "?workflow_type=" + value
      );
    },
    onFocus: function () {
      $(".selectize-input input").attr("style", "width: auto;");
    },
  });

  $(".select2-year").on("select2:select", function(e) {
    var data = e.params.data;
    console.log(data.text);
    Turbolinks.visit(
      "//" + location.host + location.pathname + "?year=" + data.text
    );
  });

  $(".tasks-filter-button").click(function (e) {
    var tasks_select2 = $("select.select2-tasks").select2();
    var created_at_select2 = $("select.select2-created-at").select2();
    var types_select2 = $("select.select2-types").select2();

    var tasksData = tasks_select2[0].value;
    var createdAtData = created_at_select2[0].value;
    var typesData = types_select2[0].value;

    Turbolinks.visit(
      "//" +
        location.host +
        location.pathname +
        "?tasks=" +
        tasksData +
        "&created_at=" +
        createdAtData +
        "&types=" +
        typesData
    );
  });

  $(".activity-history-filter-button").click(function (e) {
    var created_at_select2 = $("select.select2-created-at").select2();
    var createdAtData = created_at_select2[0].value;
    Turbolinks.visit(
      "//" + location.host + location.pathname + "?created_at=" + createdAtData
    );
  });

  if ($("#new-event.d-none")[0] == undefined) {
    $("select.selectize").selectize({
      onFocus: function () {
        $(".selectize-input input").attr("style", "width: auto;");
      },
    });

    $("select.selectize-user-assignment").selectize();
  }

  $("select.project-clients").selectize({
    placeholder: "Choose project clients",
    plugins: ["remove_button"],
    allowEmptyOption: true,
    onFocus: function () {
      $(".selectize-input input").attr("style", "width: auto;");
    },
  });

  $("select.allocation-users").selectize({
    placeholder: "Choose associates",
    plugins: ["remove_button"],
    allowEmptyOption: true,
    onFocus: function () {
      $(".selectize-input input").attr("style", "width: auto;");
    },
  });

  $("select.event-type").selectize({
    placeholder: "Choose event type",
    plugins: ["remove_button"],
    allowEmptyOption: true,
    onFocus: function () {
      $(".selectize-input input").attr("style", "width: auto;");
    },
  });

  $("select.role-select-users").selectize({
    plugins: ["remove_button"],
    delimiter: " ",
    persist: false,
    create(input) {
      return {
        value: input,
        text: input,
      };
    },
  });

  $(".conductor-filter-button").click(function (e) {
    var project_client_selectize = $("select.project-clients").selectize();
    var allocation_user_selectize = $("select.allocation-users").selectize();
    var event_type_selectize = $("select.event-type").selectize();

    var projectClientData = project_client_selectize[0].selectize.getValue();
    var allocationUserData = allocation_user_selectize[0].selectize.getValue();
    var eventTypeData = event_type_selectize[0].selectize.getValue();

    Turbolinks.visit(
      "//" +
        location.host +
        location.pathname +
        "?event_types=" +
        eventTypeData +
        "&project_clients=" +
        projectClientData +
        "&allocation_users=" +
        allocationUserData
    );
  });

  $(".select2").select2({
      minimumResultsForSearch: 5
  });
});
