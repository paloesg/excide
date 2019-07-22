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
      //format string replace all symbol with dash
      dateStr = dateStr.replace(/(^\s+|[^a-zA-Z0-9 ]+|\s+$)/g,"-");
      dateStr = dateStr.replace(/\s+/g, "-");

      //put the date to array
      var dsplit = dateStr.split("-");

      // if year cannot detect, default year is current year
      if (!dsplit[2]){
        dsplit[2] = new Date().getFullYear();
      }
      // create the date
      var d = new Date(dsplit[2],dsplit[1]-1,dsplit[0]);

      //if cannot get the date it will run create new date again with other format, because sometimes user input month with text, for example: "20 Aug"
      if (d == "Invalid Date"){
        dateStr = dsplit.join();
        d = new Date(dateStr);
        //if cannot get the date again, the default is today
        if (d == "Invalid Date"){
          d = new Date();
        }
      }
      //format date "20 Aug 2019"
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