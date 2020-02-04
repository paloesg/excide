$(document).on("turbolinks:load", function(){
  /*global moment*/
  // Check #table-batches element is exist in the page

  if ($("#table-batches").length) {

    // default start from
    let offset = 0;
    // default limit of batches
    let limit = 20;

    $.post("/symphony/batches/load_batch/", { limit: limit, offset: offset }, function(data) {}).done(function(data) {
      $(".batch-loader").remove();
      // Add batch with the details into table batches
      $.each(data["batches"], function(index, batch) {
        let indexNumber = index + offset + 1;
        $("#table-batches").append("<tr>" +
          "<td>"+ indexNumber +"</td>" +
          "<td><a href='/symphony/batches/"+ batch["template"]["slug"] +"/"+ batch["id"] +"'>"+ batch["name"] +"</a></td>" +
          "<td>"+ batch["user"]["first_name"] +" "+ batch["user"]["last_name"] +"</td>" +
          "<td>"+ moment.parseZone(batch["updated_at"]).format("YYMMDD-H:m:s") +"</td>" +
          "<td>"+ batch["workflow_progress"] +"</td>" +
          "<td>"+ batch["workflows"].length +"</td>" +
          "<td><div class='progress'><div class='progress-bar progress-bar-striped' aria-valuemax='100' aria-valuemin='0' aria-valuenow='10' role='progressbar' style='width:" + batch["task_progress"] + "%' >"  + batch["task_progress"] + "%</div></div></td>" +
          (data["is_user_superadmin"] ? "<td><button onclick='deleteBatch(\""+batch["template"]["slug"]+"\""+",\""+batch["id"]+"\")' class='btn btn-sm btn-danger'>Delete</button></td>" : "") +
        "</tr>");
      });
      $("#completed-batches").text(data["completed_batches"]);
      $("#batches-count").text(data["batches"].length);
    });
  }
});