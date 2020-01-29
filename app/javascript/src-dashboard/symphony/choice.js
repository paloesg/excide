$(document).on("turbolinks:load", function() {
  // $('select.question-choice').each(function(val){
  //   console.log("VALUE: ", val);
  // })
  // console.log('this is something: ', $('select.question-choice'));
  $('select.question-choice').on('change', function() {
    selectedValue = $(this).val();
    multipleChoiceDetails = $(this).closest('#multiple-choice-field');
    console.log("SELECTEDVALUE: ", selectedValue);
    console.log("THIS: ", $(this).closest('div').next()[0]);
    if(selectedValue == 'multiple' || selectedValue ==  'single') {
      $(this).closest('div').next().removeClass('kt-hide');
    }
    else{
      $(this).closest('div').next().addClass('kt-hide');
    }
  });
  $("#questions").on("cocoon:after-insert", function(e, addedItem) {
    $('select.question-choice').on('change', function() {
      if ($(addedItem).find('.question-choice').val() != 'multiple'){
        $(this).closest('div').next().addClass('kt-hide');
      }
      else{
        $(this).closest('div').next().removeClass('kt-hide');
      }
    });
  });
});

