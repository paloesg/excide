import Tagify from '@yaireo/tagify';
$(document).on("turbolinks:load", function () {
  const Offcanvas = require("../metronic/components/offcanvas.js");
  const quickPanel = require("../metronic/layout/extended/quick-panel.js")
  $(".drawer-row").each(function () {
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
          2: "drawer_toggle_" + dataAttribute + "_2"
        },
      }
    );
  });
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
          console.log($("#tags_count_" + id).children().eq(1))
          $("#tags_count_" + id).children()[1].innerHTML = (numOfTags-1) + "+..."
          $("#tags_count_" + id).children().eq(1).removeClass("d-none");
        }
        $("#tags_count_" + id).children()[0].innerHTML = e.detail.tagify.value[0].value;
      }
    });
  }
  // AJAX request to create or update permission
  $(".permission-document-access").on('focusin', function(){
    // Save the previous value into a data attribute called prev
    $(this).data('prev', $(this).val());
  }).on('change', function (e) {
    // Get the prev attribute value
    let prev = $(this).data('prev');
    // Get the message "saved!" to load it when AJAX request is done successfully
    let savedMessage = $(this).parent().next();
    // If prev val is "", then it should create a permission -> ajax call to create method.
    if (prev == "") {
      // post request to create permission for that role
      $.post("/motif/permissions", {
        authenticity_token: $.rails.csrfToken(),
        // Permission is the value of the dropdown ('View only' or 'Download only')
        permission: $(this).val(),
        document_id: $(this).data("document-id"),
        role_id: $(this).data("role-id")
      }).done(function(result){
        savedMessage.removeClass("d-none")
      })
    }
    else {
      // Else if prev value has value, it should update the existing value
      $.ajax({
        type: "PATCH",
        url: "/motif/permissions/" + $(this).data("permission-id"),
        data: {
          permission: $(this).val(),
          document_id: $(this).data("document-id"),
          role_id: $(this).data("role-id")
        },
        dataType: "JSON"
      }).done(function(result){
        savedMessage.removeClass("d-none")
      });
    }    
  });
  // When clicked on add-access, it will show the dropdown box 
  $(".add-access").click(function (){
    $("#add-access-" + $(this).next().data("role-id")).addClass('d-none');
    $("#add-document-access-" + $(this).next().data("role-id")).removeClass('d-none');
  })
});
