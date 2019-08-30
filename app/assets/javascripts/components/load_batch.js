
$(document).on("turbolinks:load", function() {
  var start_from = 0;
  var limit = 10;

  $.post("/symphony/batches/load_batch/"+ start_from + "/" + limit, function(batches) {
    console.log(batches);
  }).done(function(batches) {
    $.each(batches, function(index, batch) {
      $("#table-batches").append("<tr> \
      <td>"+(index + 1)+"</td> \
      <td>"+batch["name"]+"</td> \
      <td>"+batch["user"]["first_name"] +" "+ batch["user"]["last_name"] +"</td> \
      <td>"+moment.parseZone(batch["updated_at"]).format("YYMMDD-H:m:s") +"</td> \
      <td>"+batch["get_completed_workflows"] +"</td> \
      <td>"+batch["workflows"].length +"</td> \
      <td><div class='progress'><div class='progress-bar progress-bar-striped' aria-valuemax='100' aria-valuemin='0' aria-valuenow='10' role='progressbar' style='width:" + batch["action_completed_progress"] + "%' >"  + batch["action_completed_progress"] + "%</div></div></td> \
      </tr>");
    })
  })

})