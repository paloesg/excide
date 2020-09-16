$(document).on("turbolinks:load", function () {
  const Offcanvas = require("../metronic/components/offcanvas.js");
  $(".task-row").each(function () {
    let dataAttribute = $(this).data("action");
    const offcanvasObject = new Offcanvas(
      "kt_quick_notifications_" + dataAttribute,
      {
        baseClass: "offcanvas",
        overlay: true,
        closeBy: "kt_quick_notifications_close",
        toggleBy: {
          target: "kt_quick_notifications_toggle_" + dataAttribute,
          state: "mobile-toggle-active",
        },
      }
    );
  });
  $(".task-row").click(function () {
    offcanvasObject.show();
  });
});
