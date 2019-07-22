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
});