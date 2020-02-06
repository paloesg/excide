/*global moment*/
// Check #table-batches element is exist in the page

// default start from
let offset = 0;
// default limit of batches
let limit = 20;
// current page
let page = 0;

function goToBatchPage() {
  offset = page*limit;
  loadBatches();
}

function loadBatches() {
  $.post("/symphony/batches/load_batch/", { limit: limit, offset: offset }, function(data) {}).done(function(data) {
    let countPaginate = Math.ceil(data["user_batches"]/limit);

    // Reset table when load batches
    $("#table-batches > tbody > tr").remove();
    $("#batch-pagination > ul > li").remove();

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

    // Previous Page
    $("#batch-pagination > ul").append("<li class='page-item "+ ( page === 0 ? "disabled" : "" ) +"'><button class='page-link batch-pagination-button' data-page='"+ (page-1) +"'> Previous </button></li>" );

    // Navigation Pages Number
    for (i = 0; i < countPaginate; i++) {
      if (i === page) {
        // Disable link page if on the page
        $("#batch-pagination > ul").append("<li class='page-item disabled'><button class='page-link batch-pagination-button' data-page='"+ i +"'>" + (i+1) + "</button></li>" );
      } else {
        $("#batch-pagination > ul").append("<li class='page-item'><button class='page-link batch-pagination-button' data-page='"+ i +"'>" + (i+1) + "</button></li>" );
      }
    }

    // Next Page
    $("#batch-pagination > ul").append("<li class='page-item "+ ( page === (countPaginate-1) ? "disabled" : "" ) +"'><button class='page-link batch-pagination-button' data-page='"+ (page+1) +"'> Next </button></li>" );

    // Initial pagination button
    $("button.batch-pagination-button").click( (e) => {
      page = $(e.target).data("page");
      goToBatchPage();
    });

    console.log(data)

    $("#completed-batches").text(data["completed_batches"]);
    $("#batches-count").text(data["user_batches"]);
  });
}

$(document).on("turbolinks:load", function(){
  $("select#limit_batches").change( () => {
    offset = 0;
    page = 0;
    limit = $("select#limit_batches").val();
    loadBatches();
  });

  if ($("#table-batches").length) {
    loadBatches();
  }
});