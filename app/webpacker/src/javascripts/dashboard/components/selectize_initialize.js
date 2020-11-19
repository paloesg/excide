$(document).on("turbolinks:before-render", function () {
  $("select.selectize")[0].selectize.destroy();
});
$(document).on("turbolinks:load", function () {
  $(".select2-workflow-type").on("select2:select", function (e) {
    var data = e.params.data;
    Turbolinks.visit(
      "//" + location.host + location.pathname + "?workflow_type=" + data.id
    );
  });

  $(".select2-year").on("select2:select", function (e) {
    var data = e.params.data;
    Turbolinks.visit(
      "//" + location.host + location.pathname + "?year=" + data.text
    );
  });

  $(".select2-month-year").on("select2:select", function (e) {
    var data = e.params.data;
    Turbolinks.visit(
      "//" + location.host + location.pathname + "?month_year=" + data.text
    );
  });

  // For outlet view in motif
  $(".outlet-view-option").on("select2:select", function (e) {
    var data = e.params.data;
    Turbolinks.visit(
      "//" + location.host + location.pathname + "?view=" + data.id
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

  $(".documents-filter-button").click(function (e) {
    var tags_select2 = $("select.select2-document-tags").select2({
      width: 'auto'
    });
    var access_select2 = $("select.select2-document-access").select2({
      width: 'auto'
    });
    var qna_select2 = $("select.select2-document-qna").select2({
      width: 'auto'
    });

    var tagsData = tags_select2[0].value;
    var accessData = access_select2[0].value;
    var qnaData = qna_select2[0].value;

    Turbolinks.visit(
      "//" +
        location.host +
        location.pathname +
        "?tags=" +
        tagsData +
        "&access=" +
        accessData +
        "&qna=" +
        qnaData
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
  }

  $("select.project-clients").selectize({
    placeholder: "Choose project clients...",
    plugins: ["remove_button"],
    allowEmptyOption: true,
    onFocus: function () {
      $(".selectize-input input").attr("style", "width: auto;");
    },
  });

  $("select.service-line").selectize({
    placeholder: "Choose service line...",
    plugins: ["remove_button"],
    allowEmptyOption: true,
    onFocus: function () {
      $(".selectize-input input").attr("style", "width: auto;");
    },
  });

  $("select.allocation-users").selectize({
    placeholder: "Choose user...",
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
    var allocationUserSelectize = $("select.allocation-users").selectize();
    var eventTypeSelectize = $("select.event-type").selectize();
    var projectClientSelectize = $("select.project-clients").selectize();

    var projectClientData = projectClientSelectize[0].selectize.getValue();
    var allocationUserData = allocationUserSelectize[0].selectize.getValue();
    var eventTypeData = eventTypeSelectize[0].selectize.getValue();

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
    minimumResultsForSearch: 5,
    placeholder: "Select...",
  });

  $(".select2-allow-clear").select2({
    minimumResultsForSearch: 5,
    placeholder: "Select...",
    allowClear: true,
  });

  $(".timesheet-filter-button").click(function () {
    let startDate = $("#startDate").val();
    let endDate = $("#endDate").val();

    let projectClientSelectize = $("select.project-clients").selectize();
    let projectClientData = projectClientSelectize[0].selectize.getValue();

    let allocationUserSelectize = $("select.allocation-users").selectize();
    let allocationUserData = allocationUserSelectize[0].selectize.getValue();

    let serviceLineSelectize = $("select.service-line").selectize();
    let serviceLineData = serviceLineSelectize[0].selectize.getValue();

    Turbolinks.visit(
      "//" +
        location.host +
        location.pathname +
        "?start_date=" +
        startDate +
        "&end_date=" +
        endDate +
        "&project_clients=" +
        projectClientData +
        "&allocation_users=" +
        allocationUserData +
        "&service_line=" +
        serviceLineData
    );
  });

  $(".select2").select2({
    minimumResultsForSearch: 5,
    placeholder: "Select...",
  });

  $(".select2-allow-clear").select2({
    minimumResultsForSearch: 5,
    placeholder: "Select...",
    allowClear: true,
  });

  $("form").on("click", ".add_task_fields", function () {
    $(".select2").select2({
      minimumResultsForSearch: 5,
      placeholder: "Select...",
    });
    $(".select2-allow-clear").select2({
      minimumResultsForSearch: 5,
      placeholder: "Select...",
      allowClear: true,
    });
  });
});
