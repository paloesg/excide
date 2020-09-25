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
  draggable.on('drag:over:container', (res) => console.log('drag:container', res.data.sensorEvent.target));
  draggable.on('drag:stop', (res) => console.log('drag:stop', res));

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
