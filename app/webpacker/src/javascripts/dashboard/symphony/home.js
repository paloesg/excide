$(document).on("turbolinks:load", function () {
  const Offcanvas = require("../metronic/components/offcanvas.js");
  $(".task-row").each(function () {
    let dataAttribute = $(this).data("action");
    const offcanvasObject = new Offcanvas(
      "task_" + dataAttribute,
      {
        baseClass: "offcanvas",
        overlay: true,
        closeBy: "task_close_" + dataAttribute,
        toggleBy: {
          0: "task_toggle_" + dataAttribute + "_0",
          1: "task_toggle_" + dataAttribute + "_1",
          2: "task_toggle_" + dataAttribute + "_2",
          3: "task_toggle_" + dataAttribute + "_3"
        }
      }
    );
  });
});
