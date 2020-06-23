$(document).on("turbolinks:load", function() {
  // Show the form field on load
  if($('select.deadlines-type').val() === 'xth_day_of_the_month'){
    $('#template_deadline_day').closest('.form-group').removeClass('kt-hide');
    $('#template_days_to_complete').closest('.form-group').addClass('kt-hide');
  }
  else if($('select.deadlines-type').val() === 'days_to_complete'){
    $('#template_days_to_complete').closest('.form-group').removeClass('kt-hide');
    $('#template_deadline_day').closest('.form-group').addClass('kt-hide');
  }
  // Show the form field on change
  $('select.deadlines-type').on('change', function() {
    if($('select.deadlines-type').val() === 'xth_day_of_the_month'){
      $('#template_deadline_day').closest('.form-group').removeClass('kt-hide');
      $('#template_days_to_complete').closest('.form-group').addClass('kt-hide');
    }
    else if($('select.deadlines-type').val() === 'days_to_complete'){
      $('#template_days_to_complete').closest('.form-group').removeClass('kt-hide');
      $('#template_deadline_day').closest('.form-group').addClass('kt-hide');
    }
  });
  // Show the warning message if date entered are 29, 30 or 31
  $('#template_deadline_day').on('input', function(){
    if ( $('#template_deadline_day').val() === '29' || $('#template_deadline_day').val() === '30' || $('#template_deadline_day').val() === '31' ){
      $('span.deadline-warning').removeClass('kt-hide');
    }
    else{
      $('span.deadline-warning').addClass('kt-hide');
    }
  });
});
