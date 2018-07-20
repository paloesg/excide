$(function () {
  workflow_identifier_value = $('#workflow_identifier').val()
  $('#workflow_identifier').focusout(function () {
    $.get('/symphony/check-identifier?identifier=' + $('#workflow_identifier').val(), function (data) {
      new_workflow_identifier_value = $('#workflow_identifier').val().toUpperCase()
      if (workflow_identifier_value == new_workflow_identifier_value || $('#workflow_identifier').val() == '') {
        $('#workflow_identifier').removeClass('is-invalid');
        $('#workflow_identifier').removeClass('is-valid');
        $('#identifier_unique').addClass('d-none');
        $('#identifier_exist').addClass('d-none');
        $('input[type="submit"]').prop('disabled', false);
      } else if (data.unique) {
        $('#workflow_identifier').removeClass('is-invalid');
        $('#workflow_identifier').addClass('is-valid');
        $('#identifier_unique').removeClass('d-none');
        $('#identifier_exist').addClass('d-none');
        $('input[type="submit"]').prop('disabled', false);
      } else {
        $('#workflow_identifier').addClass('is-invalid');
        $('#workflow_identifier').removeClass('is-valid');
        $('#identifier_unique').addClass('d-none');
        $('#identifier_exist').removeClass('d-none');
        $('input[type="submit"]').prop('disabled', true);
      }
    });
  });
});