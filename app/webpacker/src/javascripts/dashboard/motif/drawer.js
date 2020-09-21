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
    let tagAttribute = $(this).data("tag");
    var input = document.getElementById('tag_' + tagAttribute),
      // init Tagify script on the above inputs
      tagify = new Tagify(input, {
        dropdown : {
          classname     : "tags-look",
          enabled       : 0,  
        }
      });
    // listen to "change" events on the "original" input/textarea element
    input.addEventListener('change', onTagsChange)

    // This example uses async/await but you can use Promises, of course, if you prefer.
    async function onTagsChange(e){
      console.log(tagify.value)
      // "imaginary" async function "saveToServer" should get the field's name & value
      $.ajax({
        type: "PATCH",
        url: "/motif/documents/" + tagAttribute + "/update_tags",
        data: {values: tagify.value, id: tagAttribute}
      });
    }
  });
});
