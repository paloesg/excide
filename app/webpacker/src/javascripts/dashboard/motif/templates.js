$(document).on("turbolinks:load", function () {
  $('#tasks').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
    console.log("What is e: ", e);
    console.log("What is timestamp: ", e.timeStamp);
    console.log("What is insertedItem: ", insertedItem);
    console.log("What is originalEvent: ", originalEvent);
    // Set timestamp as data attribute drawer to activate the drawer
    $(insertedItem).data("drawer", e.timeStamp);
    // Find the nearest td descendant and add drawer toggle ID to it based on it's unique timestamp 
    $(insertedItem).find("td.drawer-toggle").attr('id', 'drawer_toggle_' + $(insertedItem).data("drawer"));
    console.log("What is jquery data attr: ", $(insertedItem).data("drawer"));
    $("#tasksOffcanvas").append("<div class='offcanvas offcanvas-right offcanvas-top p-5 overflow-auto' id='drawer_task'><div class='row'><div class='col-md-11'><h5 class='d-inline'>Hello world</h5></div><div class='col-md-1'><a class='d-inline' href='#' id='drawer_close_" + e.timeStamp + "'><i class='material-icons-outlined'>close</i></a></div></div></div>");
  });

  $('#tasks').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
    const Offcanvas = require("../metronic/components/offcanvas.js");
    // Initialize the drawer row
    $(".task-drawer-row").each(function () {
      let dataAttribute = $(this).data("drawer");
      const offcanvasObject = new Offcanvas(
        "drawer_task",
        {
          baseClass: "offcanvas",
          overlay: true,
          closeBy: "drawer_close_" + dataAttribute,
          toggleBy: {
            target: "drawer_toggle_" + dataAttribute
          },
        }
      );
      console.log("WHAT is offcanvas? ", offcanvasObject);
      console.log("WHAT is dataAttribute? ", dataAttribute);
    });
  });
  
  $(".task-drawer-row").click(function () {
    console.log("What is offcanvas object?", offcanvasObject);
    offcanvasObject.show();
  });
});
