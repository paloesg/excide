$(function () {
  workflow_identifier_value = $('#workflow_identifier').val()
  $('#workflow_identifier').focusout(function () {
    $.get('/symphony/check-identifier?identifier=' + $('#workflow_identifier').val(), function (data) {
      new_workflow_identifier_value = $('#workflow_identifier').val().toUpperCase()
      if (workflow_identifier_value == new_workflow_identifier_value || $('#workflow_identifier').val() == '') {
        $('#identifier_form').removeClass('has-error');
        $('#identifier_form').removeClass('has-success');
        $('#identifier_unique').addClass('hidden');
        $('#identifier_exist').addClass('hidden');
        $('input[type="submit"]').prop('disabled', false);
      } else if (data.unique) {
        $('#identifier_form').removeClass('has-error');
        $('#identifier_form').addClass('has-success');
        $('#identifier_unique').removeClass('hidden');
        $('#identifier_exist').addClass('hidden');
        $('input[type="submit"]').prop('disabled', false);
      } else {
        $('#identifier_form').addClass('has-error');
        $('#identifier_form').removeClass('has-success');
        $('#identifier_unique').addClass('hidden');
        $('#identifier_exist').removeClass('hidden');
        $('input[type="submit"]').prop('disabled', true);
      }
    });
  });
});