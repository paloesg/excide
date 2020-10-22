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
    $("#tasksOffcanvas").append("<div class='offcanvas offcanvas-right offcanvas-top p-5 overflow-auto' id='drawer_" + e.timeStamp + "'><div class='row'><div class='col-md-11'><h5 class='d-inline'>Hello world</h5></div><div class='col-md-1'><a class='d-inline' href='#' id='drawer_close_" + e.timeStamp + "'><i class='material-icons-outlined'>close</i></a></div></div></div>");
  });
});
