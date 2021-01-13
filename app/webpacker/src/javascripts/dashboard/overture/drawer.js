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
});
