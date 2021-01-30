$(document).on("turbolinks:load", function () {
  $(".permission-icon").click(function(){
    console.log("This is clicked.", $(this).data("permission-id"));
    // Check if permission exists, if it does, then update the permission. Else, create the permission.
    if ($(this).data("permission-id")){
      $.ajax({
        type: "PATCH",
        url: "/overture/permissions/" + $(this).data("permission-id"),
        data: {
          status: $(this).data("status")
        },
        dataType: "JSON"
      }).done(function(result) {
        const linkTo = result["link_to"];
        Turbolinks.visit(linkTo);
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
        const linkTo = result["link_to"];
        Turbolinks.visit(linkTo);
      });
    }
  })
});
