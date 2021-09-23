$(document).on("turbolinks:load", function () {
  $(".permission-icon").click(function(){
    const icons = $(this).parent().find(".permission-icon");
    // Check if permission exists, if it does, then update the permission. Else, create the permission.
    if ($(this).data("permission-id")){
      $.ajax({
        type: "PATCH",
        url: "/overture/permissions/" + $(this).data("permission-id"),
        data: {
          status: $(this).data("status"),
          role_id: this.id,
        },
        dataType: "JSON"
      }).done(function(result) {
        icons.each(function() {
          // Change the css of the permission icons and tooltip description
          if (result["permissions"][`can_${$(this).data("status")}`]) {
            $(this).find("i").removeClass("text-muted");
            $(this).find("i").addClass("icon-hover");
            if ($(this).data("status") == "view") {
              $(this).attr("data-original-title", "Disable view &<br/>download access");
            } else if ($(this).data("status") == "download") {
              $(this).attr("data-original-title", "Disable download access");
            } else {
              $(this).attr("data-original-title", "Disable full access");
            }
          } else {
            $(this).find("i").addClass("text-muted");
            $(this).find("i").removeClass("icon-hover");
            if ($(this).data("status") == "view") {
              $(this).attr("data-original-title", "Give view access");
            } else if ($(this).data("status") == "download") {
              $(this).attr("data-original-title", "Give view &<br/>download access");
            } else {
              $(this).attr("data-original-title", "Give full access");
            }
          }
        });
      });
    }
    else{
      $.post("/overture/permissions", {
        authenticity_token: $.rails.csrfToken(),
        role_id: this.id,
        status: $(this).data("status"),
        permissible_id: $(this).data("permissible-id"),
        permissible_type: $(this).data("permissible-type"),
      }).done(function(result){
        // Change the css of the permission icons and tooltip description
        icons.each(function() {
          // Attach data-permission-id so that the icon triggers update method next time
          $(this).attr("data-permission-id", result["permission_id"]);
          if (result["permissions"][`can_${$(this).data("status")}`]) {
            $(this).find("i").removeClass("text-muted");
            $(this).find("i").addClass("icon-hover");
            if ($(this).data("status") == "view") {
              $(this).attr("data-original-title", "Disable view &<br/>download access");
            } else if ($(this).data("status") == "download") {
              $(this).attr("data-original-title", "Disable download access");
            } else {
              $(this).attr("data-original-title", "Disable full access");
            }
          } else {
            $(this).find("i").addClass("text-muted");
            $(this).find("i").removeClass("icon-hover");
            if ($(this).data("status") == "view") {
              $(this).attr("data-original-title", "Give view access");
            } else if ($(this).data("status") == "download") {
              $(this).attr("data-original-title", "Give view &<br/>download access");
            } else {
              $(this).attr("data-original-title", "Give full access");
            }
          }
        });
      });
    }
  })
});
