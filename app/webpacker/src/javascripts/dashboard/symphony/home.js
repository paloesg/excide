$(document).on("turbolinks:load", function () {
  $(".task-row").click(function () {
    let dataAttribute = $(this).data("action");
    console.log("WHAT IS DATA: ", dataAttribute);
    $(".trigger-offcanvas-" + dataAttribute).attr(
      "id",
      "kt_quick_panel_toggle"
    );
  });
});
