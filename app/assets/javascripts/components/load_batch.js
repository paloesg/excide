$(document).ready(function(){
  /*global moment*/
  // Check #table-batches element is exist in the page
  if ($("#table-batches").length) {
    $.post("/symphony/batches/load_batches", function(data) {}).done(function(data) {
      $(".batch-loader").remove();
      // Add batch with the details into table batches
      $.each(data["batches"], function(index, batch) {
        $("#table-batches").append("<tr>" +
          "<td>"+(index + 1)+"</td>" +
          "<td><a href='batches/"+ batch["template"]["slug"] +"/"+ batch["id"] +"'>"+ batch["name"] +"</a></td>" +
          "<td>"+ batch["user"]["first_name"] +" "+ batch["user"]["last_name"] +"</td>" +
          "<td>"+ moment.parseZone(batch["updated_at"]).format("YYMMDD-H:m:s") +"</td>" +
          "<td>"+ batch["get_completed_workflows"] +"</td>" +
          "<td>"+ batch["workflows"].length +"</td>" +
          "<td><div class='progress'><div class='progress-bar progress-bar-striped' aria-valuemax='100' aria-valuemin='0' aria-valuenow='10' role='progressbar' style='width:" + batch["action_completed_progress"] + "%' >"  + batch["action_completed_progress"] + "%</div></div></td>" +
        "</tr>");
      });
      $("#completed-batches").text(data["completed_batches"]);
      $("#batches-count").text(data["batches"].length);
    });
  }

  if ($("#table-batch").length) {
    $.post("/symphony/batches/load_batch", { id: $("#batch_id").val() } ).done(function(data) {
      console.log(data)

      $.each(data["sections"], function(index, section) {
        $("#table-batch").append(
          "<div class='card scrollbar mb-3' id='section-"+section["id"]+"'>" +
            "<h5 class='card-header'>" +
              section["section_name"] + " - " + section["tasks"].length + " tasks" +
              "<div class='pull-right'>" + data["completed_workflow_count"] + " of " + data["batch"]["workflows"].length + " files completed</div>" +
            "</h5>" +
            "<div class='card-body'>" +
              "<table class='table table-hover'>" +
                "<thead>" +
                  "<tr>" +
                    "<th> Documents </th>" +
                    "<th> Invoices </th>" +
                  "</tr>" +
                "</thead>" +
              "</table>" +
            "</div>" +
          "</div>"
        );
      })
      $.each(data["sections"], function(index, section) {
        $.each(section["tasks"], function(index, task) {
          $("#section-"+section["id"]+" .card-body > table > thead > tr").append(
            "<th>" +
              "<a class='pop' data-container='body' title='"+ task["role"]["display_name"] +"' data-content='<div>"+task["instructions"]+"</div>' data-html='true' data-placement='top' data-toggle='append-new-popover' data-trigger='hover' >" +
                "<div class='header-properties'>" +
                  task["task_type"] +
                  " <i class='ti-info-alt'></i>" +
                "</div>" +
                "<div class='header-info'>" +
                  task["role"]["name"] +
                "</div>" +
              "</a>" +
            "</th>"
          );
        })
      })

    });
  }
});