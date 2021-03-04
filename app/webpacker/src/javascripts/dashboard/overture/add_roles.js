$(document).on("turbolinks:load", function () {
  $("select.overture-select-user-types").change(function(){
    // Find the rendered select2 form field
    let selectContainer = $(this).next().find(".select2-selection__rendered")
    $.ajax({
      type: "POST",
      url: "/overture/add-roles",
      data: {
        role_id: $(this).val(),
        user_id: $(this).attr('id'),
      },
      dataType: "JSON"
    })
    .done(function(data){
      // If success request, it will change the border of the form to green color for a short while
      selectContainer.css({ "border": "1px solid #B8CD59"})
      setTimeout(function(){
        selectContainer.css({ "border": "1px solid #B5B5C3"})
      }, 3000);
    }).fail(function(data) {
      // If fail, it will be red
      selectContainer.css({ "border": "1px solid red"})
      setTimeout(function(){
        selectContainer.css({ "border": "1px solid #B5B5C3"})
      }, 3000);
    })
  })
});
