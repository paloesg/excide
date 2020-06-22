$(document).on("turbolinks:load", function() {
  if($('select#deadlines-type').val() === 'xth_day_of_the_month'){
    $('#template_deadline_day').closest('.form-group').removeClass('kt-hide');
    $('#template_days_to_complete').closest('.form-group').addClass('kt-hide');
  }
  else if($('select#deadlines-type').val() === 'days_to_complete'){
    $('#template_days_to_complete').closest('.form-group').removeClass('kt-hide');
    $('#template_deadline_day').closest('.form-group').addClass('kt-hide');
  }
  
  $('select#deadlines-type').on('change', function() {
    console.log("OPTION VALUE: ", $('select#deadlines-type').val());
    console.log("days to comple VALUE: ", $('#template_days_to_complete').closest('.form-group'));
    if($('select#deadlines-type').val() === 'xth_day_of_the_month'){
      $('#template_deadline_day').closest('.form-group').removeClass('kt-hide');
      $('#template_days_to_complete').closest('.form-group').addClass('kt-hide');
    }
    else if($('select#deadlines-type').val() === 'days_to_complete'){
      $('#template_days_to_complete').closest('.form-group').removeClass('kt-hide');
      $('#template_deadline_day').closest('.form-group').addClass('kt-hide');
    }
  });
});
