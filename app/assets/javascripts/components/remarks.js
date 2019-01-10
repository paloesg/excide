$(document).ready(function(){
  $( document ).ajaxSuccess(function(){
    $(".special").text("AJAX SUCCESSFULY DONE!");
  })
})