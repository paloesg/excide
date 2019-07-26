$(document).on("turbolinks:load", function() {
  $(".thumb-holder").append('<div class="thumb-zoom"></div>')
  $( ".thumb-holder" ).mousemove(function(event) {  
    var offset =  $(this).offset();
    var zoomX = event.pageX - offset.left - 70 ;
    var zoomY = event.pageY - offset.top  - 90; 
    console.log("[event.pageX] :", zoomX);
    console.log("[event.pageY] :", zoomY);
    $('.thumb-zoom').css({
     'left' :zoomX + 50,
     'top': zoomY -20, 
    })  
    var position =  $( ".thumb-zoom" ).position();
    var image = $(".thumbnail").attr('src');
    
    $('.thumb-zoom').html('<img id="zoom-img" src="'+ image +'" >');
    $("#zoom-img").css({
      'left' : -zoomX -133,
      'top': -zoomY, 
    })
  });    
});