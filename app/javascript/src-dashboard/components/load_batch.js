/*global moment*/
// Check #table-batches element is exist in the page

// default of 'start from'
let offset = 0;
// default limit of batches
let limit = 20;
// current page
let currentPage = 0;
// limit Pages of Pagination (limit right left of current page)
let limitPage = 3;

// This is for default value exceed left or right, not settings
let exceedLeft = false;
let exceedRight = false;

function goToBatchPage() {
  offset = currentPage*limit;
  return new loadBatches();
}

function limitPagination(totalPages) {
  let getLimitPages = []

  if (currentPage === 0 || currentPage === (totalPages-1)) {
    lmt = limitPage*2;
  } else {
    lmt = limitPage;
  }

  for (i = 0; i < totalPages; i++) {
    if (i < (currentPage-lmt)) {
      exceedLeft = true;
    } else if (i <= (currentPage+lmt)) {
      getLimitPages.push(i)
    } else {
      exceedRight = true;
    }
  }

  return getLimitPages;
}

function loadBatches() {
  $(".loading").show();
  $.post("/symphony/batches/load_batch/", { limit: limit, offset: offset }, function(data) {}).done(function(data) {
    $(".loading").hide();
    let countPaginate = Math.ceil(data["user_batches"]/limit);
    let arrayPages = [];

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

    arrayPages = limitPagination(countPaginate);

    if (currentPage !== 0) {
      // The first page of pagination
      $("#batch-pagination > ul").append("<li class='page-item'><button class='page-link batch-pagination-button' data-page='"+ 0 +"'> First </button></li>" );

      // Previous Page Button
      $("#batch-pagination > ul").append("<li class='page-item'><button class='page-link batch-pagination-button' data-page='"+ (currentPage-1) +"'> Previous </button></li>" );
    }

    // Left dots exceed
    if (exceedLeft) {
      $("#batch-pagination > ul").append("<li class='page-item disabled'><button class='page-link batch-pagination-button' > .... </button></li>" );
    }

    $.each(arrayPages, (index, value) => {
      if (value === currentPage) {
        // Disable link page if on the page
        $("#batch-pagination > ul").append("<li class='page-item active'><button class='page-link' data-page='"+ value +"'>" + (value+1) + "</button></li>" );
      } else {
        $("#batch-pagination > ul").append("<li class='page-item'><button class='page-link batch-pagination-button' data-page='"+ value +"'>" + (value+1) + "</button></li>" );
      }
    });

    // Right dots exceed
    if (exceedRight) {
      $("#batch-pagination > ul").append("<li class='page-item disabled'><button class='page-link batch-pagination-button' > .... </button></li>" );
    }

    if (currentPage !== (countPaginate-1)) {
      // Next Page Button
      $("#batch-pagination > ul").append("<li class='page-item'><button class='page-link batch-pagination-button' data-page='"+ (currentPage+1) +"'> Next </button></li>" );

      // The last page of pagination (countPaginate-1)
      $("#batch-pagination > ul").append("<li class='page-item'><button class='page-link batch-pagination-button' data-page='"+ (countPaginate-1) +"'> Last </button></li>" );
    }

    // Initial pagination button
    $("button.batch-pagination-button").click( (e) => {
      currentPage = $(e.target).data("page");
      goToBatchPage();
    });

    $("#completed-batches").text(data["completed_batches"]);
    $("#batches-count").text(data["user_batches"]);
    // Reset value exceed
    exceedLeft = false;
    exceedRight = false;
  });
}

// When the first time page loaded
$(document).on("turbolinks:load", function(){
  $("select#limit_batches").change( () => {
    offset = 0;
    currentPage = 0;
    limit = $("select#limit_batches").val();
    loadBatches();
  });

  if ($("#table-batches").length) {
    loadBatches();
  }
});