$(document).on("turbolinks:load", function() {
  // Detect zoomed-image before load image
  $(".zoomed-image").each(function (k, v) { v.src = v.src; });

  var img;
  var zoom;
  zoom = 1.5;
  img = $("img.zoomed-image");
  //load the image to get the proper height of the image after it is loaded, but have to off the 'load', so that it loads the image on refresh (this is to prevent the function not working on refresh)
  img.off("load").on("load", function(){
    var glass, imageUrl, w, h, bw;
    /* Create magnifier glass: */
    glass = $("<div>");
    glass.addClass("img-magnifier-glass");
    /* Insert magnifier glass: */
    img.parent()[0].insertBefore(glass[0], img[0]);
    /* Set background properties for the magnifier glass: */
    imageUrl = "url('" + img[0].src + "')";
    glass.css({
      "background-image": imageUrl,
      "background-repeat": "no-repeat",
      "background-size": (img[0].width * zoom) + "px " + (img[0].height * zoom) + "px"
    });
    bw = 3;
    w = glass[0].offsetWidth / 2;
    h = glass[0].offsetHeight / 2;

    function getCursorPos(e) {
      var a, x = 0, y = 0;
      e = e || window.event;
      /* Get the x and y positions of the image: */
      a = img[0].getBoundingClientRect();
      // Calculate the cursor's x and y coordinates, relative to the image:
      x = e.pageX - a.left;
      y = e.pageY - a.top;
      /* Consider any page scrolling: */
      x = x - window.pageXOffset;
      y = y - window.pageYOffset;
      return {x, y};
    }

    //display zoom in image in the magnifying glass
    function glassPosition(x, y){
      glass.css({
        "left": (x - w) + "px",
        "top": (y - h) + "px",
        // Display what the magnifier glass "sees":
        "background-position": "-" + ((x * zoom) - w + bw) + "px -" + ((y * zoom) - h + bw) + "px",
      });
    }

    //Prevent the magnifier glass from being positioned outside the image, and set glassPosition
    function magnifierConditions(x, y){
      //nested yMagnifierConditions inside xMagnifierConditions to prevent cyclomatic complexity error (calling too many linearly independent paths for a function)
      function yMagnifierConditions(x, y){
        //calculate the y-position for magnifier conditions
        if (y > img[0].height - (h / zoom)) {  y = img[0].height - (h / zoom);}
        if (y < h / zoom) { y = h / zoom;}
        glassPosition(x, y);
      }
      //calculate the x-position for magnifier conditions
      if (x > img[0].width - (w / zoom)){ x = img[0].width - (w / zoom);}
      if (x < w / zoom) { x = w / zoom;}
      yMagnifierConditions(x, y);
    }

    function moveMagnifier(e) {
      var pos;
      /* Prevent any other actions that may occur when moving over the image */
      e.preventDefault();
      /* Get the cursor's x and y positions: */
      pos = getCursorPos(e);
      magnifierConditions(pos.x, pos.y);
    }

    /* Execute a function when someone moves the magnifier glass over the image: */
    glass.on("mousemove", moveMagnifier);
    img.on("mousemove", moveMagnifier);

    /*and also for touch screens:*/
    glass.on("touchmove", moveMagnifier);
    img.on("touchmove", moveMagnifier);
  });
});