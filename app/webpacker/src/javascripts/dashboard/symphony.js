$(document).on("turbolinks:load", function () {
  $(".select2").select2({
    dropdownParent: "body",
    width: "resolve",
  });

  $(".submit-next").click(function () {
    $(".submit-position").val("next_page");
  });

  $(".submit-back").click(function () {
    $(".submit-position").val("previous_page");
  });

  $(".btn-invoice-approved").click(function () {
    $(".invoice-status").val("approved");
  });

  $(".btn-invoice-rejected").click(function () {
    $(".invoice-status").val("rejected");
  });

  $("form").on("click", ".remove_fields", function (event) {
    $(this).closest("tr").find(".destroy").val("1");
    $(this).closest("tr").hide();
    return event.preventDefault();
  });
  //removing a line_item in the invoice
  $("form").on("click", ".remove_line_items", function (event) {
    $(this).closest("tr").find(".destroy").val("1");
    $(this).closest("tr").remove();
    return event.preventDefault();
  });
  //removing a task in template
  $("form").on("click", ".remove_tasks", function (event) {
    $(this).prev("input[type=hidden]").val("1");
    $(this).closest("tr").hide();
    // Remove all the required validation to skip html5 validation error
    $(this).closest("tr").find("td input").removeAttr("required");
    $(this).closest("tr").find("td textarea").removeAttr("required");
    return event.preventDefault();
  });

  $("form").on("click", ".remove_segments", function (event) {
    $(this).closest("div").find(".destroy").val("1");
    $(this)
      .closest("div")
      .parent()
      .closest("div")
      .parent()
      .closest("div.question-block")
      .remove();
    return event.preventDefault();
  });

  $("form").on("click", ".remove_choices", function (event) {
    $(this).closest("div").find(".destroy").val("1");
    $(this)
      .closest("div")
      .parent()
      .closest("div")
      .parent()
      .closest("div.choice-block")
      .remove();
    return event.preventDefault();
  });

  //General way of adding attribute through link_to_add_row method in application helper
  $("form").on("click", ".add_task_fields", function (event) {
    let regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data("id"), "g");
    $(".task-in-section-" + $(this).data("sectionId")).append(
      $(this).data("fields").replace(regexp, time)
    );
    //Loop section count to get the index of the section's array
    $(".section-count").each(function (index) {
      $(
        "select[id$='template_sections_attributes_" +
          index +
          "_tasks_attributes_" +
          time +
          "_task_type']"
      ).select2({
        dropdownParent: "body",
      });
      $(
        "select[id$='template_sections_attributes_" +
          index +
          "_tasks_attributes_" +
          time +
          "_role_id']"
      ).select2({
        dropdownParent: "body",
      });
      $(
        "select[id$='template_sections_attributes_" +
          index +
          "_tasks_attributes_" +
          time +
          "_child_workflow_template_id']"
      ).select2({
        dropdownParent: "body",
      });
      $(
        "select[id$='template_sections_attributes_" +
          index +
          "_tasks_attributes_" +
          time +
          "_document_template_id']"
      ).select2({
        dropdownParent: "body",
      });
      $(
        "select[id$='template_sections_attributes_" +
          index +
          "_tasks_attributes_" +
          time +
          "_survey_template_id']"
      ).select2({
        dropdownParent: "body",
      });
      $(
        "select[id$='template_sections_attributes_" +
          index +
          "_tasks_attributes_" +
          time +
          "_user_id']"
      ).select2({
        dropdownParent: "body",
      });
      // Selectize for deadline type when adding NEW tasks
      $(
        "select[id$='template_sections_attributes_" +
          index +
          "_tasks_attributes_" +
          time +
          "_deadline_type']"
      ).select2({
        dropdownParent: "body",
      });
      // Show deadline warning message on NEW task
      $("select.task-deadlines-type").each(function () {
        $(
          "select[id$=template_sections_attributes_" +
            index +
            "_tasks_attributes_" +
            time +
            "_deadline_type"
        ).on("change", function () {
          if (
            $(
              "select[id$=template_sections_attributes_" +
                index +
                "_tasks_attributes_" +
                time +
                "_deadline_type"
            ).val() === "xth_day_of_the_month"
          ) {
            $(".task-deadline-warning").removeClass("d-none");
          } else {
            $(".task-deadline-warning").addClass("d-none");
          }
        });
      });
      $(".data-attributes").find("tr:last-child").find(".create").val("1");
      return event.preventDefault();
    });
    //if radio button is checked, disable or enable the relevant fields
    $("input:radio[name='radioContact']").click(function () {
      if ($(this).val() == "existing") {
        $(".new-disable").attr("disabled", true);
        $(".existing-contact-disable")[0].selectize.enable();
      } else {
        $(".existing-contact-disable")[0].selectize.disable();
        $(".new-disable").attr("disabled", false);
      }
    });
    return $("input").change(function (event) {
      return $(this).closest("td").next().find(".update").val("1");
    });
    return event.preventDefault();
  });

  $("form").on("click", ".add_choice_fields", function (event) {
    let regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data("id"), "g");
    $(".choice-in-question-" + $(this).data("questionId")).append(
      $(this).data("fields").replace(regexp, time)
    );
    return event.preventDefault();
  });

  $("form").on("click", ".add_segment_fields", function (event) {
    let regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data("id"), "g");
    $(".segment-in-survey-section-" + $(this).data("surveySectionId")).append(
      $(this).data("fields").replace(regexp, time)
    );
    return event.preventDefault();
  });

  //auto-fills the file field with file name
  $(".custom-file-input").change(function() {
    var fileName = $(this).val().split("\\").pop();
    $(this).siblings(".custom-file-label").addClass("selected").html(fileName);
  });

  //if radio button is checked, disable or enable the relevant fields
  $('input:radio[name="radioContact"]').click(function () {
    if ($(this).val() == "existing") {
      $(".new-disable").attr("disabled", true);
      $(".existing-contact-disable")[0].selectize.enable();
    } else {
      $(".existing-contact-disable")[0].selectize.disable();
      $(".new-disable").attr("disabled", false);
    }
  });
  return $("input").change(function (event) {
    return $(this).closest("td").next().find(".update").val("1");
  });
});

// A workaround to ensure that zendesk widget works with turbolinks
window.addEventListener("turbolinks:before-render", function () {
  window.zEACLoaded = void 0;
});
