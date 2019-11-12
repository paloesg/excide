$(document).on("turbolinks:load", function(){
  if ($('#card-element').length) {
    var stripe = Stripe($('input[name=stripe_key]').val());
    var elements = stripe.elements();

    var card = elements.create('card',{hidePostalCode: true,});
    card.mount('#card-element');
    
    card.addEventListener('change', function(event) {
      var submit_button = $('input[type="submit"]')
      var displayError = $('#card-errors');
      if(event.error) {
        displayError.attr('class', 'stripe-alert-error')    
        displayError.text(event.error.message);
        submit_button.attr('disabled', true);
      }
      else {
        displayError.attr('class', '')    
        displayError.text('');
        submit_button.removeAttr('disabled');
      }
    });

    $("form.additional-information-page").submit(function(event){
      event.preventDefault();
      stripe.createToken(card).then(function(result) {
        if (result.error) {
          var displayError = $('#card-errors');
          displayError.attr('class', 'stripe-alert-error')    
          displayError.text(result.error.message);
          var submit_button = $('input[type="submit"]')
          submit_button.removeAttr('disabled');
        } else {
          stripeTokenHandler(result.token);
        }
      })
    });
  }


  $('.update-credit-card').change(function() {
    if(this.checked) {
      var stripe = Stripe($('input[name=stripe_key]').val());
      var elements = stripe.elements();

      var card = elements.create('card',{hidePostalCode: true,});
      card.mount('#card-element-update');
      
      card.addEventListener('change', function(event) {
        var submit_button = $('input[type="submit"]')
        var displayError = $('#card-errors');
        if(event.error) {
          displayError.attr('class', 'stripe-alert-error')    
          displayError.text(event.error.message);
          submit_button.attr('disabled', true);
        }
        else {
          displayError.attr('class', '')    
          displayError.text('');
          submit_button.removeAttr('disabled');
        }
      });

      $("form.edit-user-page").submit(function(event){
        event.preventDefault();
        stripe.createToken(card).then(function(result) {
          if (result.error) {
            var displayError = $('#card-errors');
            displayError.attr('class', 'stripe-alert-error')    
            displayError.text(result.error.message);
            var submit_button = $('input[type="submit"]')
            submit_button.removeAttr('disabled');
          } else {
            stripeTokenHandler(result.token);
          }
        })
      });
    }
    else {
      $('#card-element-update').empty();
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
