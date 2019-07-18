$(document).on("turbolinks:load", function() {
  $(".datetimepicker").datetimepicker({
    format: "YYYY-MM-DD HH:mm",
    stepping: 15
  });

  $(".datepicker").datetimepicker({
    format: "YYYY-MM-DD",
  });

  $('.timepicker').datetimepicker({
    format: 'HH:mm',
    stepping: 15
  });


  //auto convert date

  var tabKeyPressed = false;

  $(".autodate").keydown(function(e) {
    tabKeyPressed = e.keyCode == 9;
    if (tabKeyPressed) {
      e.preventDefault();
      return;
    }
  });

  $(".autodate").keyup(function(e) {
    if (tabKeyPressed) {
      let dateStr = $(this).val();
      let dateVar = dateStr.replace(/[\. ,:-]+/g, "-");
      var dsplit = dateVar.split("-");
      if (!dsplit[2]){
        dsplit[2] = new Date().getFullYear();
      }

      var d = new Date(dsplit[2],dsplit[1]-1,dsplit[0]);

      if (d == "Invalid Date"){
        dateVar = dsplit.join();
        d = new Date(dateVar);
        if (d == "Invalid Date"){
          d = new Date();
        }
      }
      d = moment(d).format("D MMM YYYY")
      $(this).val(d);
      e.preventDefault();
      return;
    }
  });

  $(".dateinvoice").datetimepicker({
    format: "D MMM YYYY",
  });
});