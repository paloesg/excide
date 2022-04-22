import Tagify from '@yaireo/tagify';
$(document).on("turbolinks:load", function () {
  const Offcanvas = require("../metronic/components/offcanvas.js");

  let offcanvasClick = function(dataAttribute){
    event.stopPropagation();
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
          3: "drawer_toggle_" + dataAttribute + "_3",
          4: "drawer_toggle_" + dataAttribute + "_4",
          5: "drawer_toggle_" + dataAttribute + "_5"
        },
      }
    );
    offcanvasObject.show();
  }
  window.offcanvasClick = offcanvasClick;
  
  let tagifyInstances = []; //for the each loop below
  $(".motif-tags").each(function () {
    let input = $(this).attr("id")
    let path = $(this).data("path")
    tagifyInstances.push(
      new Tagify(document.getElementById(input), {
        dropdown: {
          classname: "tags-look",
          enabled: 0
        },
        autoComplete: {
          rightKey: true
        },
        callbacks: {
          "change": (e) => onTagsChange(e, input.split('_')[1], path)
        }
      })
    );
  });
  async function onTagsChange(e, id, path){
    $.ajax({
      type: "PATCH",
      url: path + id + "/update_tags",
      data: {values: e.detail.tagify.value, id: id},
      dataType: "JSON"
    }).done(function(data){
      $.each(tagifyInstances, function() {
        $(this)[0].settings.whitelist = data;
      });
      // Changes the tag label(index 0) and tags count(index 1) dynamically
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
          $("#tags_count_" + id).children()[1].innerHTML = (numOfTags-1) + "+..."
          $("#tags_count_" + id).children().eq(1).removeClass("d-none");
        }
        $("#tags_count_" + id).children()[0].innerHTML = e.detail.tagify.value[0].value;
      }
    });
  }
});
