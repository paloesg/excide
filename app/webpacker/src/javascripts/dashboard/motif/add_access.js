// For document repository offcanvas
window.addAccess = function(formElement) {
  // When clicked on add-access, it will show the dropdown box
  // Make ID unique with role id and permissible id
  $("#add-access-link-" + $(formElement).parent().next().data("user-id") + "-" + $(formElement).parent().next().data("permissible-id")).addClass('d-none');
  $("#add-access-" + $(formElement).parent().next().data("user-id") + "-" + $(formElement).parent().next().data("permissible-id")).removeClass('d-none');
};
