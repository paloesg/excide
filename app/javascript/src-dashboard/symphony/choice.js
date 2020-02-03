$(document).on("turbolinks:load", function() {
  $('select.question-choice').on('change', function() {
    var selectedValue = $(this).val();
    var multipleChoiceDetails = $(this).closest('#multiple-choice-field');
    console.log("Seelected val: ", selectedValue);
    console.log("MC Details: ", $(this).closest('div').next());
    if(selectedValue === 'multiple' || selectedValue ===  'single') {
      $(this).closest('div').next().removeClass('kt-hide');
    }
    else{
      $(this).closest('div').next().addClass('kt-hide');
    }
  });
  $("#questions").on("cocoon:after-insert", function(e, addedItem) {
    $('select.question-choice').on('change', function() {
      // Check if the added item value is undefined, only run the function if its defined. This is to prevent the code from crashing when we add choices instead of questions.
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

