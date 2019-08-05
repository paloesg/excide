$(document).on("turbolinks:load", function() { 
  function magnify(imgID, zoom) {
    var $img;
    $img = $("." + imgID);
    //load the image to get the proper height of the image after it is loaded, but have to off the 'load', so that it loads the image on refresh (this is to prevent the function not working on refresh)
    $img.off("load").on("load", function(){
      var glass, imageUrl, w, h, bw;
      /* Create magnifier glass: */
      glass = $("<div>");
      glass.addClass("img-magnifier-glass");
      /* Insert magnifier glass: */
      $img.parent()[0].insertBefore(glass[0], $img[0]);
      /* Set background properties for the magnifier glass: */
      imageUrl = "url('" + $img[0].src + "')";
      glass.css({
        "background-image": imageUrl,
        "background-repeat": "no-repeat",
        "background-size": ($img[0].width * zoom) + "px " + ($img[0].height * zoom) + "px"
      });
      bw = 3;
      w = glass[0].offsetWidth / 2;
      h = glass[0].offsetHeight / 2;

      function getCursorPos(e) {
        var a, x = 0, y = 0;
        e = e || window.event;
        /* Get the x and y positions of the image: */
        a = $img[0].getBoundingClientRect();
        // Calculate the cursor's x and y coordinates, relative to the image: 
        x = e.pageX - a.left;
        y = e.pageY - a.top;
        /* Consider any page scrolling: */
        x = x - window.pageXOffset;
        y = y - window.pageYOffset;
        return {x, y};
      };
      
      function moveMagnifier(e) {
        var pos, x, y;
        /* Prevent any other actions that may occur when moving over the image */
        e.preventDefault();
        /* Get the cursor's x and y positions: */
        pos = getCursorPos(e);
        x = pos.x;
        y = pos.y;
        /* Prevent the magnifier glass from being positioned outside the image: */
        if (x > $img[0].width - (w / zoom)){x = $img[0].width - (w / zoom);}
        if (x < w / zoom) {x = w / zoom;}
        if (y > $img[0].height - (h / zoom)) {y = $img[0].height - (h / zoom);}
        if (y < h / zoom) {y = h / zoom;}

        /* Set the position of the magnifier glass: */
        glass.css({
          "left": (x - w) + "px",
          "top": (y - h) + "px",
          // Display what the magnifier glass "sees": 
          "background-position": "-" + ((x * zoom) - w + bw) + "px -" + ((y * zoom) - h + bw) + "px",
        });
      };

      /* Execute a function when someone moves the magnifier glass over the image: */
      glass.on("mousemove", moveMagnifier);
      $img.on("mousemove", moveMagnifier);

      /*and also for touch screens:*/
      glass.on("touchmove", moveMagnifier);
      $img.on("touchmove", moveMagnifier);
    });
  }
  //check for the container before magnifying
  if($(".img-magnifier-container").length){
    magnify("zoomed-image", 1.5);
  }
});