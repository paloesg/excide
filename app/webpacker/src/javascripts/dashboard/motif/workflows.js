// Condition to do a strikethrough when checkbox is checked
$(document).on("turbolinks:load", function () {
  $('input.action_checkbox').each(function () {
    if ($(this).is(':checked')) {
      $(this).closest('tr').find('td').first().addClass('task-instructions');
    }
  });
});
