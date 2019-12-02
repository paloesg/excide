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
  if ($("#table-batches").length) {
    $.post("/symphony/batches/load_batch/", function(data) {}).done(function(data) {
      $(".batch-loader").remove();
      // Add batch with the details into table batches
      $.each(data["batches"], function(index, batch) {
        $("#table-batches").append("<tr>" +
          "<td>"+(index + 1)+"</td>" +
          "<td><a href='symphony/batches/"+ batch["template"]["slug"] +"/"+ batch["id"] +"'>"+ batch["name"] +"</a></td>" +
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
});
