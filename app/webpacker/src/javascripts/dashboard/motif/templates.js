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
            0: "drawer_toggle_" + dataAttribute + "_0",
            1: "drawer_toggle_" + dataAttribute + "_1",
            2: "drawer_toggle_" + dataAttribute + "_2",
            3: "drawer_toggle_" + dataAttribute + "_3"
          },
        }
      );
    });
  }

  initializeDrawer();

  $("[data-form-prepend]").click(function(e) {
    let obj = $($(this).attr("data-form-prepend"));
    let standardizedCurrentTime = new Date().getTime();
    // Add an ID to the drawer table row that links to the drawer ID (this is so we can remove the drawer when removing the nested form)
    obj.attr('id', "drawer_task_" + standardizedCurrentTime);
    // Set current time as data attribute drawer to activate the drawer
    obj.attr("data-drawer", standardizedCurrentTime);
    // Find the nearest td descendant and add drawer toggle ID to it based on the current time 
    obj.find("td.drawer-toggle").each(function(index){
      $( this ).attr('id', 'drawer_toggle_' + standardizedCurrentTime + '_' + index);
    })
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
    // Replace all the form input name with the standardized current time
    $("#tasksOffcanvas").find("input, select, textarea").each(function() {
      $(this).attr("name", function() {
        return $(this)
          .attr("name")
          .replace("[tasks_attributes][", "[tasks_attributes][" + standardizedCurrentTime);
      });
    });
    // Add an ID to the close button with the data drawer after initializing the drawer
    $("#drawer_task_" + standardizedCurrentTime).find("a").attr('id', 'drawer_close_' + standardizedCurrentTime);
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

  $("form").on("click", ".remove_motif_tasks", function (event) {
    // Find draw row ID and match it to the offcanvas
    let drawerRowId = $(this).closest("tr.task-drawer-row").attr("id")
    // Find offcanvas that matches the drawer row ID
    let drawerToDelete = $("#tasksOffcanvas").find("#" + drawerRowId)
    // Remove nested form
    $(this).closest("tr").remove();
    // For NEW template form
    if(drawerToDelete.length){
      // Remove drawer that links to the nested form
      drawerToDelete.remove()
    } // For EDIT template form 
    else {
      // Delete nested attributes by setting value to 1 for both drawer and nested form
      $(this).closest("tr").find(".destroy").val("1");
      $("#" + drawerRowId).find(".destroy").val("1")
      // Hide both the drawer and the nested form
      $("#" + drawerRowId).hide();
      $(this).closest("tr").hide();
    }
    
    return event.preventDefault();
  });
});
