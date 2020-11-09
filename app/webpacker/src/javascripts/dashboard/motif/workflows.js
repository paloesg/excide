// Condition to do a strikethrough when checkbox is checked
$(document).on("turbolinks:load", function () {
  $('input.action_checkbox').each(function () {
    console.log("Checkbox: ", $(this).is(':checked'))
    console.log("task: ", $(this).closest('tr').find('td'))
    if ($(this).is(':checked')) {
        $(this).closest('tr').find('td').first().addClass('task-instructions');
    }
  });
});
