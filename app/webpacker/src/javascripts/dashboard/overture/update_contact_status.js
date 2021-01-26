$(document).on("turbolinks:load", function () {
  $(".select2-change-contact-status").change(function(){
    console.log("What is element: ", $("#" + this.id).next(".select2").find(".select2-selection"))
    $.ajax({
      type: "PATCH",
      url: "/overture/contacts/" + this.id,
      data: {
        contact_type: "change-contact-status-dropdown",
        contact_status_id: this.value,
      },
      dataType: "JSON"
    });
  })
});
