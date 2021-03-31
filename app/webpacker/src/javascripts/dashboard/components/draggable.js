import { Sortable } from '@shopify/draggable';

$(document).on("turbolinks:load", function() {
  let containers = document.querySelectorAll('.draggable-columns');
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

  // This function checks for the classes to prevent dragging on. For eg, the link into the card should be clickable.
  const isPrevented = (element, classesToPrevent) => {
    let currentElem = element;
    let isIncluded = false;

    while (currentElem) {
      // Check whether there are any classes in the current element that are to be prevented
      const hasClass = Array.from(currentElem.classList).some((cls) => classesToPrevent.includes(cls));
      if (hasClass) {
        isIncluded = true;
        currentElem = undefined;
      } else {
        currentElem = currentElem.parentElement;
      }
    }
    return isIncluded;
  }
  // Check for any prevented class to be drag on drag:start and then cancel the event.
  sortable.on('drag:start', (event) => {
    const currentTarget = event.originalEvent.target;

    if (isPrevented(currentTarget, ['clickable-contact'])) {
      event.cancel();
    }
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
  });
});
