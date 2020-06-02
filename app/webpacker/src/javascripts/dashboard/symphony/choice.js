$(document).on("turbolinks:load", function() {
  // Loop through all the question type and reveal the choices if selected option is multiple or single
  $('select.question-choice').each(function(){
    if(($(this).children("option:selected").val() == 'multiple') || ($(this).children("option:selected").val() == 'single')){
      $('div#multiple-choice-field').removeClass('kt-hide');
    }
  })
  $('select.question-choice').on('change', function() {
    var selectedValue = $(this).val();
    var multipleChoiceDetails = $(this).closest('#multiple-choice-field');
    if(selectedValue === 'multiple' || selectedValue ===  'single') {
      $(this).closest('div').next().removeClass('kt-hide');
    }
    else{
      $(this).closest('div').next().addClass('kt-hide');
    }
  });
  $(".questions").on("cocoon:after-insert", function(e, addedItem) {
    $('select.question-choice').on('change', function() {
      // Only run the function if the added item value is defined. This is to prevent the code from crashing when we add choices instead of questions.
      if ( ($(addedItem).find('.question-choice').val()) ){
        if ($(addedItem).find('.question-choice').val() === 'multiple' || $(addedItem).find('.question-choice').val() === 'single'){
          $(this).closest('div').next().removeClass('kt-hide');
        }
        else{
          $(this).closest('div').next().addClass('kt-hide');
        }
      }   
    });
  });
});

