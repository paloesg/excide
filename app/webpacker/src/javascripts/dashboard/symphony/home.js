$(document).on("turbolinks:load", function () {
  const Offcanvas = require("../metronic/components/offcanvas.js");
  $(".task-row").each(function () {
    let dataAttribute = $(this).data("action");
    const offcanvasObject = new Offcanvas(
      "task_" + dataAttribute,
      {
        baseClass: "offcanvas",
        overlay: true,
        closeBy: "task_close",
        toggleBy: {
          target: "task_toggle_" + dataAttribute,
          state: "mobile-toggle-active",
        },
      }
    );
  });
  $(".task-row").click(function () {
    offcanvasObject.show();
  });
});
