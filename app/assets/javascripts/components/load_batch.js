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
        // Card sections
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
                "</thead><tbody></tbody>" +
              "</table>" +
            "</div>" +
          "</div>"
        );
        // Task header & popover
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
        // Table data of document, invoice
        $.each(data["batch"]["workflows"].reverse(), function(index, workflow) {
          $("#section-"+section["id"]+" .card-body > table > tbody").append(
            "<tr id='wf_"+workflow["id"]+"'>" +
              "<td class='documents'>Display Docs</td>" +
              "<td class='invoice'>Display Invoice</td>" +
            "</tr>"
          )
          // Set position of tasks, before add workflow actions to the table data
          $.each(section["tasks"], function(index, task) {
            $("#section-"+section["id"]+" .card-body > table > tbody > tr#wf_"+workflow["id"]).append(
              "<td id='"+task["id"]+"'>"+task["id"]+"</td>"
            );
          })
        })
      })

      // Table data of workflow actions
      $.each(data["batch"]["workflows"], function(index, workflow) {
        $.each(workflow["workflow_actions"], function(index, action) {
          if (action["completed"]) {
            $("#section-"+action["task"]["section_id"]+" .card-body > table > tbody > #wf_"+workflow["id"]+" > td#"+action["task"]["id"]).replaceWith(
              "<td class='text-center'><div class='completed-task'>" +
                "<i class='fa fa-check-circle text-success ml-3'></i>" +
              "</div></td>"
            )
          } else {
            $("#section-"+action["task"]["section_id"]+" .card-body > table > tbody > #wf_"+workflow["id"]+" > td#"+action["task"]["id"]).replaceWith(
              "<td class='text-center'><a role='button' class='btn btn-success btn-sm mb-2' href='/symphony/"+data["batch"]["template"]["slug"]+"/"+workflow["id"]+"/invoices/new?invoice_type=payable&workflow_action_id="+action["id"]+"'>Start</a></td>"
            )
          }
        })
      })

      $("a[data-toggle='append-new-popover']").popover()
      // $("a[data-toggle='append-new-popover']").popover().on("shown.bs.popover", function() {
      //   var this_popover = $(this).data("bs.popover").tip;
      //   $(this_popover).css({
      //     top: '50px'
      //   });
      // })
    });
  }
});