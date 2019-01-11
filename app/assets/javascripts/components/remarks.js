$(document).ready(function(){
  $( document ).ajaxSuccess(function(){
    $(".special-626").text("Remark submitted!");
    $(".remarks-update").innerHTML("Changed!")
  })
})