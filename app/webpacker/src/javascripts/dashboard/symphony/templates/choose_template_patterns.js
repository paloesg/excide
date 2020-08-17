$(document).on("turbolinks:load", function() {
  // When selecting to create
  $('select#template_template_pattern').on('change', function(){
    if ($('select#template_template_pattern').val() === 'monthly'){
      $('.template-date-range').removeClass('d-none');
      $('.template-date-range').find('input').attr("disabled", false);
    }
    else {
      $('.template-date-range').addClass('d-none');
      $('.template-date-range').find('input').attr("disabled", true);
    }
  });

  // Show the form field on load
  if($('select#template_template_pattern').val() === 'monthly'){
    $('.template-date-range').removeClass('d-none');
    $('.template-date-range').find('input').attr("disabled", false);
  }
  else{
    $('.template-date-range').addClass('d-none');
    $('.template-date-range').find('input').attr("disabled", true);
  }
});
