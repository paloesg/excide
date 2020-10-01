import { Draggable } from '@shopify/draggable';
import { Droppable } from '@shopify/draggable';
$(document).on("turbolinks:load", function() {
  let containers = document.querySelectorAll('.draggable-zone');
  if (containers.length === 0) {
      return false;
  }
  const draggable = new Draggable(containers, {
    draggable: '.draggable',
    handle: '.draggable .draggable-handle',
  });
  // Define a variable to store the lastest element that user dragged a file over
  let source;
  draggable.on("drag:over", (e) => {
    // Store the element that a file was dragged into
    source = e;
    // $("#" + source.data.over.closest('tr').id).css({ "border": "4px dashed blue" })
  });

  draggable.on("drag:stop", (e) => {
    // On release, send an AJAX reqeust to store file into folder
    let tableRow = source.data.over.closest('tr')
    $.ajax({
      type: "PATCH",
      url: "/motif/documents/" + source.data.originalSource.id,
      data: {
        document_id: source.data.originalSource.id, 
        folder_id: tableRow.id
      },
      dataType: "JSON"
    }).done((result) => {
      const linkTo = result["link_to"];
      Turbolinks.visit(linkTo);
    });
    // execute your drop action: e.originalSource on lastOver
    source = undefined;
  });
});
