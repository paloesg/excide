$(document).on("turbolinks:load", function(){
  if($('.break-inside-avoid').length > 20) {
    $('#company-dropdown').addClass("col3");
  }
  else if($('.break-inside-avoid').length > 10){
    $('#company-dropdown').addClass("col2");
  }
});
