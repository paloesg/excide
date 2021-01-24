import { Sortable } from '@shopify/draggable';

$(document).on("turbolinks:load", function() {
  console.log("Dragon and dungeon!");
  let containers = document.querySelectorAll('.draggable-columns');
  console.log("Container", containers);

  if (containers.length === 0) {
      return false;
  }
  const sortable = new Sortable(containers, {
    draggable: '.draggable',
    handle: '.draggable .draggable-handle',
    mirror: {
      constrainDimensions: true,
    },
  });

  sortable.on('sortable:stop', (e) => {
    // Only update contacts record when new container is different from old container (user don't drag the card into the same zone)
    if (e.data.newContainer !== e.data.oldContainer) {
      $.ajax({
        type: "PATCH",
        url: "/overture/contacts/" + e.data.dragEvent.data.originalSource.id,
        data: {
          contact_status_id: e.data.newContainer.id,
        },
        dataType: "JSON"
      });
    }
    console.log('sortable:stop', e.data.newContainer !== e.data.oldContainer);
  });
});
