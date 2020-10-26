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
    // Select the task drawer base and attached a unique id to it
    $("#task_drawer_base > div").attr("id", "drawer_task_" + e.timeStamp);
    console.log("task drawer base: ", $("#task_drawer_base > div"))
    // Append the html of the task drawer to the tasksOffcanvas div
    $("#tasksOffcanvas").append($("#task_drawer_base").html());
    // Remove appended task_drawer_base so that we wont have 2 offcanvas with form
    $("#task_drawer_base").empty();
    console.log("appended!")

  });

  $('#tasks').on('cocoon:after-insert', function(e, insertedItem, originalEvent) {
    const Offcanvas = require("../metronic/components/offcanvas.js");
    // Initialize the drawer row
    $(".task-drawer-row").each(function () {
      let dataAttribute = $(this).data("drawer");
      const offcanvasObject = new Offcanvas(
        "drawer_task_" + dataAttribute,
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
});
