"use strict";
import Sortable from '@shopify/draggable/lib/sortable';
var KTCardDraggable = function() {

    return {
        //main function to initiate the module
        init: function() {
            var containers = document.querySelectorAll('.draggable-zone');

            if (containers.length === 0) {
                return false;
            }

            var swappable = new Sortable(containers, {
                draggable: '.draggable',
                handle: '.draggable .draggable-handle',
                mirror: {
                    //appendTo: selector,
                    appendTo: 'body',
                    constrainDimensions: true
                }
            });
        }
    };
}();

jQuery(document).ready(function() {
    KTCardDraggable.init();
});
