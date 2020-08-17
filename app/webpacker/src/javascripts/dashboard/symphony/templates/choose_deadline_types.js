$(document).on("turbolinks:load", function() {
  // Show the form field on load
  if($('select.deadlines-type').val() === 'xth_day_of_the_month'){
    $('.xth-day').removeClass('d-none');
    // Disable the form input if it's not shown so that it doesn't submit twice
    $('.xth-day').find('input').attr("disabled", false);
    $('.days-to-complete').addClass('d-none');
    $('.days-to-complete').find('input').attr("disabled", true);
  }
  else if($('select.deadlines-type').val() === 'days_to_complete'){
    $('.days-to-complete').removeClass('d-none');
    $('.days-to-complete').find('input').attr("disabled", false);
    $('.xth-day').addClass('d-none');
    $('.xth-day').find('input').attr("disabled", true);
  }
  // Show the form field on change
  $('select.deadlines-type').on('change', function() {
    if($('select.deadlines-type').val() === 'xth_day_of_the_month'){
      $('.xth-day').removeClass('d-none');
      $('.xth-day').find('input').attr("disabled", false);
      $('.days-to-complete').addClass('d-none');
      $('.days-to-complete').find('input').attr("disabled", true);
    }
    else if($('select.deadlines-type').val() === 'days_to_complete'){
      $('.days-to-complete').removeClass('d-none');
      $('.days-to-complete').find('input').attr("disabled", false);
      $('.xth-day').addClass('d-none');
      $('.xth-day').find('input').attr("disabled", true);
    }
  });
  // Show the warning message if date entered are 29, 30 or 31
  $('.xth-day').find('input').on('input', function(){
    if ( $('.xth-day').find('input').val() === '29' || $('.xth-day').find('input').val() === '30' || $('.xth-day').find('input').val() === '31' ){
      $('span.deadline-warning').removeClass('d-none');
    }
    else{
      $('span.deadline-warning').addClass('d-none');
    }
  });
//-----------------------------Deadline type through tasks-------------------------
  
  $("select.task-deadlines-type").each(function(index){
    $(".section-count").each(function (sectionIndex) {
      $("select[id$=template_sections_attributes_" + sectionIndex + "_tasks_attributes_" + index + "_deadline_type").on("change", function(){
        if ($("select[id$=template_sections_attributes_" + sectionIndex + "_tasks_attributes_" + index + "_deadline_type").val() === 'xth_day_of_the_month'){
          $(".task-deadline-warning").removeClass('d-none');
        }
        else{
          $(".task-deadline-warning").addClass('d-none');
        }
      });    
    });
  }); 
});
