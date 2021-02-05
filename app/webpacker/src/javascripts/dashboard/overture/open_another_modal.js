$(document).on("turbolinks:load", function () {
  $("#sendOvertureInvitation").on('show.bs.modal', function (e) {
      $("#addInvestmentOverture").modal("hide");
  });
});
