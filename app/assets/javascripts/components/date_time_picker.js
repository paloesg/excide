$(function () {
  $(".datetimepicker").datetimepicker({
    format: "YYYY-MM-DD HH:mm",
  });

  $(".datepicker").datetimepicker({
    format: "YYYY-MM-DD",
  });

  $('.timepicker').datetimepicker({
    format: 'HH:mm',
    stepping: 15
  });
});
