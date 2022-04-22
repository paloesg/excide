window.setPrevValue = function(formElement) {
  // Save the previous value into a data attribute called prev
  $(formElement).data('prev', $(formElement).val());
};

window.setPermission = function(formElement){
  // Get the prev attribute value
  let prev = $(formElement).data('prev');
  // Get the message "saved!" to load it when AJAX request is done successfully
  let savedMessage = $(formElement).parent().next();
  // If prev val is "", then it should create a permission -> ajax call to create method.
  if (prev == "") {
    // post request to create permission for that role
    $.post("/motif/permissions", {
      authenticity_token: $.rails.csrfToken(),
      // Permission is the value of the dropdown ('View only' or 'Download only')
      permission: $(formElement).val(),
      user_id: $(formElement).data("user-id"),
      // Permissible type determines if its getting from folder or document
      permissible_type: $(formElement).data("permissible-type"),
      permissible_id: $(formElement).data("permissible-id")
    }).done(function(result){
      savedMessage.removeClass("d-none")
    })
  }
  else {
    // Else if prev value has value, it should update the existing value
    $.ajax({
      type: "PATCH",
      url: "/motif/permissions/" + $(formElement).data("permission-id"),
      data: {
        permission: $(formElement).val(),
        // Permissible type determines if its getting from folder or document
        permissible_type: $(formElement).data("permissible-type"),
        permissible_id: $(formElement).data("permissible-id"),
        user_id: $(formElement).data("user-id")
      },
      dataType: "JSON"
    }).done(function(result){
      savedMessage.removeClass("d-none")
    });
  }
}