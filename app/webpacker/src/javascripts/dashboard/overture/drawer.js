$(document).on("turbolinks:load", function () {
  const Offcanvas = require("../metronic/components/offcanvas.js");
  $(".overture-drawer-row").each(function () {
    let dataAttribute = $(this).data("drawer");
    const offcanvasObject = new Offcanvas(
      "drawer_" + dataAttribute,
      {
        baseClass: "offcanvas",
        overlay: true,
        closeBy: "drawer_close_" + dataAttribute,
        toggleBy: {
          0: "drawer_toggle_" + dataAttribute + "_0",
          1: "drawer_toggle_" + dataAttribute + "_1",
          2: "drawer_toggle_" + dataAttribute + "_2",
        },
      }
    );
  });
  // AJAX request to create or update permission
  $(".overture-permission-document-access").on('focusin', function(){
    // Save the previous value into a data attribute called prev
    $(this).data('prev', $(this).val());
  }).on('change', function (e) {
    // Get the prev attribute value
    let prev = $(this).data('prev');
    // Get the message "saved!" to load it when AJAX request is done successfully
    let savedMessage = $(this).parent().next();
    // If prev val is "", then it should create a permission -> ajax call to create method.
    if (prev == "") {
      // post request to create permission for that role
      $.post("/overture/permissions", {
        authenticity_token: $.rails.csrfToken(),
        // Permission is the value of the dropdown ('View only' or 'Download only')
        permission: $(this).val(),
        user_id: $(this).data("user-id"),
        // Permissible type determines if its getting from folder or document
        permissible_type: $(this).data("permissible-type"),
        permissible_id: $(this).data("permissible-id")
      }).done(function(result){
        savedMessage.removeClass("d-none")
      })
    }
    else {
      // Else if prev value has value, it should update the existing value
      $.ajax({
        type: "PATCH",
        url: "/overture/permissions/" + $(this).data("permission-id"),
        data: {
          permission: $(this).val(),
          // Permissible type determines if its getting from folder or document
          permissible_type: $(this).data("permissible-type"),
          permissible_id: $(this).data("permissible-id"),
          user_id: $(this).data("user-id")
        },
        dataType: "JSON"
      }).done(function(result){
        savedMessage.removeClass("d-none")
      });
    }
  });
  // When clicked on add-access, it will show the dropdown box
  $(".overture-add-access").click(function (){
    // Make ID unique with role id and permissible id
    $("#overture-add-access-link-" + $(this).next().data("user-id") + "-" + $(this).next().data("permissible-id")).addClass('d-none');
    $("#overture-add-access-" + $(this).next().data("user-id") + "-" + $(this).next().data("permissible-id")).removeClass('d-none');
  })
});
