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
  let tagifyInstances = [];
  $(".motif-tags").each(function () {
    let input = $(this).attr("id")
      // init Tagify script on the above inputs
    tagifyInstances.push(
      new Tagify(document.getElementById(input), {
        dropdown : {
          classname     : "tags-look",
          enabled       : 0
        },
        autoComplete: {
          rightKey: true
        },
        callbacks: {
          "change": (e) => onTagsChange(e, input.split('_')[1])
        }
      })
    );
    // listen to "change" events on the "original" input/textarea element
  });
  // This example uses async/await but you can use Promises, of course, if you prefer.
  async function onTagsChange(e, id){
    // "imaginary" async function "saveToServer" should get the field's name & value
    $.ajax({
      type: "PATCH",
      url: "/motif/documents/" + id + "/update_tags",
      data: {values: e.detail.tagify.value, id: id},
      dataType: "JSON"
    }).done(function(data){
      $.each(tagifyInstances, function() {
        $(this)[0].settings.whitelist = data;
      });
      const numOfTags = e.detail.tagify.value.length;
      if (numOfTags == 0) {
        $("#tags_count_" + id).children().eq(0).addClass("d-none");
      }
      else {
        if (numOfTags < 2) {
          $("#tags_count_" + id).children().eq(1).addClass("d-none")
          $("#tags_count_" + id).children().eq(0).removeClass("d-none");
        }
        else {
          console.log($("#tags_count_" + id).children().eq(1))
          $("#tags_count_" + id).children()[1].innerHTML = (numOfTags-1) + "+..."
          $("#tags_count_" + id).children().eq(1).removeClass("d-none");
        }
        $("#tags_count_" + id).children()[0].innerHTML = e.detail.tagify.value[0].value;
      }
    });
  }
});
