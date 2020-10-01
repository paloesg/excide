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
    console.log("what is source: ", $("#" + source.data.over.closest('tr').id));
    // $("#" + source.data.over.closest('tr').id).css({ "border": "4px dashed blue" })
  });

  draggable.on("drag:stop", (e) => {
    // On release, send an AJAX reqeust to store file into folder
    console.log("source 2", source);
    console.log("source 2", source.data);
    console.log("target closest TR", source.data.over.closest('tr'));
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
      console.log("WHAT IS result: ", result);
      const linkTo = result["link_to"];
      Turbolinks.visit(linkTo);
    });
    // execute your drop action: e.originalSource on lastOver
    source = undefined;
    console.log("2nd new source", source)
  });

  // draggable.on('drag:over:container', (res) => console.log('drag:container', res.data.sensorEvent.target));
  // draggable.on('drag:stop', (res) => console.log('drag:stop', res));

  // draggable.on('drag:out', (res) => {
  //   console.log('targeted_tr', res.sensorEvent.target.closest("tr"));
  //   console.log('dragged_element', res.data.originalSource.id);
  //   let targeted_tr = res.sensorEvent.target.closest("tr");
  //   let dragged_element_id = res.data.originalSource.id;
  //   $.ajax({
  //     type: "get",
  //     url: "/motif/hello_world",
  //     dataType: "json",
  //   }).done(function(data) {
  //     console.log("DONED!", data);
  //   });
  // });
});
