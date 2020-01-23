$(document).on("turbolinks:load", function() {
  $('select.question-choice').on('change', function() {
    selectedValue = $(this).val();
    multipleChoiceDetails = $(this).closest('.multiple-choice-field');
    console.log("SELECTEDVALUE: ", selectedValue);
    console.log("THIS: ", $(this).closest('td').closest('tr').next()[0]);
    if(selectedValue != 'multiple') {
      $(this).closest('td').closest('tr').next().addClass('kt-hide');
    }
    else{
      $(this).closest('td').closest('tr').next().removeClass('kt-hide');
    }
    // if(selectedValue == TRUE) { guarantorDetails.hide(); } 
    // else { guarantorDetails.show(); }

  });
});
