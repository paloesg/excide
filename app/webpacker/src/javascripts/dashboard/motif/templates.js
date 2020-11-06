$(document).on("turbolinks:load", function () {
  let initializeDrawer = () => {
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
    });
  }

  initializeDrawer();

  $("[data-form-prepend]").click(function(e) {
    let obj = $($(this).attr("data-form-prepend"));
    let standardizedCurrentTime = new Date().getTime();
    // Set current time as data attribute drawer to activate the drawer
    obj.data("drawer", standardizedCurrentTime);
    // Find the nearest td descendant and add drawer toggle ID to it based on the current time 
    obj.find("td.drawer-toggle").attr('id', 'drawer_toggle_' + standardizedCurrentTime);
    obj.find("input, select, textarea").each(function() {
      $(this).attr("name", function() {
        return $(this)
          .attr("name")
          .replace("new_record", standardizedCurrentTime);
      });
    });
    $("tbody.motif-tasks").append(obj);
    // Select the task drawer base and attached a unique id to it
    $("#task_drawer_base > div").attr("id", "drawer_task_" + standardizedCurrentTime);
    // Append the html of the task drawer to the tasksOffcanvas div
    $("#tasksOffcanvas").append($("#task_drawer_base").html());
    console.log("WHta is input,", $("#tasksOffcanvas").find("input, select, textarea"))
    // Replace all the form input name with the standardized current time
    $("#tasksOffcanvas").find("input, select, textarea").each(function() {
      $(this).attr("name", function() {
        return $(this)
          .attr("name")
          .replace("[tasks_attributes][0]", "[tasks_attributes][" + standardizedCurrentTime + "]");
      });
    });
    initializeDrawer();
    return false;
  });

  $("#motif_new_template").submit(function(){
    // Remove appended task_drawer_base so that we wont have 2 offcanvas with form
    $("#task_drawer_base").empty();
  });

  $("#motif_edit_template").submit(function(){
    // Remove appended task_drawer_base so that we wont have 2 offcanvas with form
    $("#task_drawer_base").empty();
  });
});
