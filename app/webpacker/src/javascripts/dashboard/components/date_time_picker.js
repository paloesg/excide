function changeDateValue(dateStr){
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
  d = moment(d).format("D MMM YYYY");
  return d;
}

$(document).on("turbolinks:load", function() {
  $(".datetimepicker").datetimepicker({
    format: "YYYY-MM-DD HH:mm",
    stepping: 15
  });

  $(".datepicker").datetimepicker({
    format: "YYYY-MM-DD"
  });

  $('.timepickers').datetimepicker({
    format: 'HH:mm',
    stepping: 15
  });


  //auto convert date
  $(".autodate").keydown(function (event) {
    // check if tab keyboard button pressed
    if (event.keyCode === 9) {
      let dateStr = $(this).val();
      // Check if the 1st character is + 
      if (dateStr.slice(0, 1) === "+"){
        if ($(".invoicedate").val()){
          let date = new Date($(".invoicedate").val());
          let dueDate = date.setDate(date.getDate() + parseInt(dateStr, 10));
          let d = moment(dueDate).format("D MMM YYYY");
          $(".duedate").val(d);
        }
        else{
          $(".duedate").val("Invalid Date");
        }
      }
      else{
        // do change the field value with date format
        $(this).val(changeDateValue(dateStr));
      }
    }
  });

  

  $(".dateinvoice").datetimepicker({
    format: "D MMM YYYY",
  });
});
