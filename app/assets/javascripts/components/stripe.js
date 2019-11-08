$(document).on("turbolinks:load", function() {
  if ($('#card-element').length) {
    var stripe = Stripe($('input[name=stripe_key]').val());
    var elements = stripe.elements();

    var card = elements.create('card');
    card.mount('#card-element');
    
    card.addEventListener('change', function(event) {
      // Check input( $( this ).val() ) for validity here
      var displayError = $('#card-errors');
      if(event.error) {
        displayError.attr('class', 'alert alert-danger')    
        displayError.text(event.error.message);
      }
      else {
        displayError.attr('class', '')    
        displayError.text('');
      }
    });
    $("form#edit_user").submit(function(event){
      event.preventDefault()
      stripe.createToken(card).then(function(result) {
        if (result.error) {
          var displayError = $('#card-errors');
          displayError.attr('class', 'alert alert-danger')    
          displayError.text(result.error.message);
          var submit_button = $('.additional-information-submit')
          submit_button.removeAttr('disabled');
        } else {
          stripeTokenHandler(result.token);
        }
      })
    });
  }
});
  
function stripeTokenHandler(token) {
  // Insert the token ID into the form so it gets submitted to the server
  var form = document.getElementById('edit_user');
  var hiddenInput = document.createElement('input');
  hiddenInput.setAttribute('type', 'hidden');
  hiddenInput.setAttribute('name', 'user[stripe_card_token]');
  hiddenInput.setAttribute('value', token.id);
  form.appendChild(hiddenInput);

  // Submit the form
  form.submit();
}
