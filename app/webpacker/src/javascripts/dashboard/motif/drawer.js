import Tagify from '@yaireo/tagify';
$(document).on("turbolinks:load", function () {
  const Offcanvas = require("../metronic/components/offcanvas.js");
  $(".drawer-row").each(function () {
    let dataAttribute = $(this).data("drawer");
    const offcanvasObject = new Offcanvas(
      "drawer_" + dataAttribute,
      {
        baseClass: "offcanvas",
        overlay: true,
        closeBy: "drawer_close",
        toggleBy: {
          target: "drawer_toggle_" + dataAttribute,
          state: "mobile-toggle-active",
        },
      }
    );
  });
  $(".drawer-row").click(function () {
    offcanvasObject.show();
  });
  $(".motif-tags").each(function () {
    let input = $(this).attr("id")
      // init Tagify script on the above inputs
    new Tagify(document.getElementById(input), {
      dropdown : {
        classname     : "tags-look",
        enabled       : 0
      },
      callbacks: {
        "change": (e) => onTagsChange(e, input.split('_')[1])
      }
    });
    // listen to "change" events on the "original" input/textarea element
  });
  // This example uses async/await but you can use Promises, of course, if you prefer.
  async function onTagsChange(e, id){
    //console.log(e);
    // "imaginary" async function "saveToServer" should get the field's name & value
    $.ajax({
      type: "PATCH",
      url: "/motif/documents/" + id + "/update_tags",
      data: {values: e.detail.tagify.value, id: id}
    });
  }
});
