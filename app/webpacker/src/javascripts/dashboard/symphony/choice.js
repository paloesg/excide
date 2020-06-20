$(document).on("turbolinks:load", function() {
  // Show all the choices after cocoon save when the select value is single or multiple
  // Loop through all the question choice and then remove kt-hide for #multiple-choice-field
  $('select.question-choice').each(function(){
    if(($(this).children("option:selected").val() == 'multiple') || ($(this).children("option:selected").val() == 'single')){
      $(this).closest('div').next().removeClass('kt-hide');
    }
  })

  // This is when the user edits the question type on an existing survey template. If the user selects multiple or single in the dropdown, the choice button will appear upon chosen. 
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

  // This is when the user haven't save the survey template and added a new question through cocoon. Only run the function if the added item value is defined. This is to prevent the code from crashing when we add choices instead of questions.
  $(".questions").on("cocoon:after-insert", function(e, addedItem) {
    $('select.question-choice').on('change', function() {
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

