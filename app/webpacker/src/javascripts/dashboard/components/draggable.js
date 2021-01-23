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
  });

  sortable.on('sortable:start', () => console.log('sortable:start'));
  sortable.on('sortable:sort', () => console.log('sortable:sort'));
  sortable.on('sortable:sorted', () => console.log('sortable:sorted'));
  sortable.on('sortable:stop', () => console.log('sortable:stop'));
});
