$(document).on("turbolinks:load", function() {
  var stripe = Stripe('pk_test_QSqR9niHI76R9dmfZETPjEmE00F3Hm3VEy');
  var elements = stripe.elements();

  var card = elements.create('card');
  card.mount('#card-element');

  card.addEventListener('change', function(event) {
    var displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.setAttribute('class', 'alert alert-danger');
      displayError.textContent = event.error.message;
    } else {
      displayError.setAttribute('class', '');
      displayError.textContent = '';
    }
  });

  var form = document.getElementById('edit_user');
  
  form.addEventListener('submit', function(event) {
    stripe.createToken(card).then(function(result) {
      if (result.error) {
        // Inform the user if there was an error
        var errorElement = document.getElementById('card-errors');
        errorElement.setAttribute('class', 'alert alert-danger');
        errorElement.textContent = result.error.message;
        return false;
      } else {
        // Send the token to your server
        stripeTokenHandler(result.token);
      }
    });
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
});
