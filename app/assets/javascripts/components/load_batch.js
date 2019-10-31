function deleteBatch(template, id){
  if (confirm("Are you sure you want to delete this batch and all its data?")) {
    $(".loading").show();
    $.ajax({
      url: "batches/"+ template +"/"+ id,
      type: "DELETE",
      success(result) {
        $(".loading").hide();
      }
    });
  }
}

$(document).ready(function(){
  /*global moment*/
  // Check #table-batches element is exist in the page

  function startButtonLink(action, workflow, batch) {
    let url = "";
    let invoiceId = "";
    if (workflow["invoice"]) {
      invoiceId = workflow["invoice"]["id"];
    }
    switch (action["task"]["task_type"]) {
      case "create_invoice_payable": url = "/symphony/"+batch["template"]["slug"]+"/"+workflow["id"]+"/invoices/new?invoice_type=payable&workflow_action_id="+action["id"]; break;
      case "create_invoice_receivable": url = "/symphony/"+batch["template"]["slug"]+"/"+workflow["id"]+"/invoices/new?invoice_type=reiceivable&workflow_action_id="+action["id"]; break;
      case "xero_send_invoice": url = "/symphony/"+batch["template"]["slug"]+"/"+workflow["id"]+"/invoices/"+invoiceId+"/edit?workflow_action_id="+action["id"]; break;
      case "approval": url = "/symphony/"+batch["template"]["slug"]+"/"+workflow["id"]+"/complete_task/"+action["id"]; break;
    }
    return url;
  }

  function humanize(str) {
    var frags = str.split("_");
    for (var i=0; i<frags.length; i++) {
      frags[parseInt(i)] = frags[parseInt(i)].charAt(0).toUpperCase() + frags[parseInt(i)].slice(1);
    }
    return frags.join(" ");
  }

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
          (data["is_user_superadmin"] ? "<td><button onclick='deleteBatch(\""+batch["template"]["slug"]+"\""+",\""+batch["id"]+"\")' class='btn btn-sm btn-danger'>Delete</button></td>" : "") +
        "</tr>");
      });
      $("#completed-batches").text(data["completed_batches"]);
      $("#batches-count").text(data["batches"].length);
    });
  }

  if ($("#table-batch").length) {
    $.post("/symphony/batches/load_batch", { id: $("#batch_id").val() } ).done(function(data) {
      // console.log(data);
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
                  humanize(task["task_type"]) +
                  " <i class='ti-info-alt'></i>" +
                "</div>" +
                "<div class='header-info'>" +
                  humanize(task["role"]["name"]) +
                "</div>" +
              "</a>" +
            "</th>"
          );
        })
        // Table data of document, invoice
        $.each(data["batch"]["workflows"].reverse(), function(index, workflow) {
          let invoiceLink = "";
          let tableDataInvoice = "<i class='ti-receipt icon mr-3 text-center medium-icon gray-icon'></i>";
          let workflowDocument = "<i class='ti-file icon mr-3 text-center large-icon gray-icon'></i>";

          if (workflow["invoice"]){
            invoiceLink = "/symphony/"+data["batch"]["template"]["slug"]+"/"+workflow["id"]+"/invoices/"+workflow["invoice"]["id"];
            tableDataInvoice = "<a href='"+invoiceLink+"'><i class='ti-receipt icon mr-3 medium-icon'></i></a>";
          }

          if (workflow["documents"].length) {
            workflowDocument = "";
            let documentPreview = "";
            $.each(workflow["documents"], function(index, doc) {
              var ext = doc["file_url"].substring(doc["file_url"].lastIndexOf(".") + 1);
              if (ext === "pdf") {
                documentPreview = doc["filename"]+"<br><a class='pdf-preview' data-container='body' data-content data-document='https:"+doc["file_url"]+"' data-placement='auto' tabindex='0' data-original-title title>Preview</a>";
              } else {
                documentPreview = doc["filename"]+"<br><a data-container='body' data-content='<img src=\""+doc["file_url"]+"\" class=\"img-fluid\">' data-html='true' data-toggle='popover' data-trigger='focus' tabindex='0' data-original-title title>Preview</a>";
              }
              workflowDocument = workflowDocument + " " + documentPreview;
            })
          }

          $("#section-"+section["id"]+" .card-body > table > tbody").append(
            "<tr id='wf_"+workflow["id"]+"'>" +
              "<td class='documents'>"+ workflowDocument +"</td>" +
              "<td class='invoice'>"+tableDataInvoice+"</td>"+
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

      // Start button or completed sign of workflow actions
      $.each(data["batch"]["workflows"], function(index, workflow) {
        sortWorkflowActions = workflow["workflow_actions"].sort(function(a,b) {
          return new Date (b["created_at"]) - new Date (a["created_at"])
        })
        $.each(sortWorkflowActions, function(index, action) {
          let linkTo = "";
          let disabledButton = "disabled";
          linkTo = startButtonLink(action, workflow, data["batch"]);
          if (action["completed"]) {
            $("#section-"+action["task"]["section_id"]+" .card-body > table > tbody > #wf_"+workflow["id"]+" > td#"+action["task"]["id"]).replaceWith(
              "<td class='action text-center completed'><div class='completed-task'>" +
                "<i class='fa fa-check-circle text-success ml-3'></i>" +
              "</div></td>"
            )
          } else {
            $("#section-"+action["task"]["section_id"]+" .card-body > table > tbody > #wf_"+workflow["id"]+" > td#"+action["task"]["id"]).replaceWith(
              "<td class='action text-center'><a role='button' class='btn btn-success btn-sm mb-2 "+disabledButton+"' href='"+linkTo+"'>Start</a></td>"
            )
          }
        })
      })

      // Do not disable button for next task if previous task is completed
      $.each(data["batch"]["workflows"], function(index, workflow) {
        $.each(workflow["workflow_actions"], function(index, action) {
          if (index+1 === workflow["workflow_actions"].length) {
            workflowRow = $("#section-"+action["task"]["section_id"]+" .card-body > table > tbody > #wf_"+workflow["id"]).find("td.action");
            $.each(workflowRow, function(index, td) {
              if (index===0 || $(td).prev().hasClass("completed")) {
                $(td).find("a").removeClass("disabled");
              }
            })
          }
        })
      })

      // Call initial popover for document preview
      $("a[data-toggle='popover']").popover()
      $(".pdf-preview").popover({
        html : true,
        placement : "auto",
        trigger : "focus",
        sanitize : false,
        content() {
          return "<iframe src='https://docs.google.com/viewer?url=" + $(this).attr("data-document") + "&embedded=true' frameborder='0' height='300px' width='250px'></iframe>";
        }
      });
    });
  }
});
