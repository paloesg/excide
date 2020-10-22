$(document).on("turbolinks:load", function () {
  $('#tasks').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
    console.log("What is e: ", e);
    console.log("What is timestamp: ", e.timeStamp);
    console.log("What is insertedItem: ", insertedItem);
    console.log("What is originalEvent: ", originalEvent);
    // Set timestamp as data attribute drawer to activate the drawer
    $(insertedItem).data("drawer", e.timeStamp);
    // Find the nearest td descendant and add drawer toggle ID to it based on it's unique timestamp 
    $(insertedItem).find("td.drawer-toggle").attr('id', 'drawer_toggle_' + $(insertedItem).data("drawer") +'_0');
    console.log("What is jquery data attr: ", $(insertedItem).data("drawer"));
    console.log("WHat is hello world: ", $(".hello-world"))
  });
});
