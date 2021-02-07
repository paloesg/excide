// Disable submit button if text field is empty
$(document).on("turbolinks:load", function () {
  $('.sendButton').prop('disabled',true);
  $('#chat-message').bind("change keyup input", function(){
    $('.sendButton').prop('disabled', this.value == "" ? true : false);
  })
})
