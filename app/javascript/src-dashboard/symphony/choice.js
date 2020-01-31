$(document).on("turbolinks:load", function() {
  // $('select.question-choice').each(function(val){
  //   console.log("VALUE: ", val);
  // })
  // console.log('this is something: ', $('select.question-choice'));
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
  $("#questions").on("cocoon:after-insert", function(e, addedItem) {
    $('select.question-choice').on('change', function() {
      if ($(addedItem).find('.question-choice').val() === 'multiple' || $(addedItem).find('.question-choice').val() === 'single'){
        $(this).closest('div').next().removeClass('kt-hide');
      }
      else{
        $(this).closest('div').next().addClass('kt-hide');
      }
    });
  });
});

