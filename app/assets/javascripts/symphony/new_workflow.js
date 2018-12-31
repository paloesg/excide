$(document).ready(function(){
  var $detached = true;
  $detached = $(".form-for-new-client").detach();

  $(".existing-client-header").click(function(){
    if ( $detached ) {
      $("#headingTwo").click(function(){
        $('#cardBody').append($detached);
        $detached = null;
      })
    }
    else{
      $detached = $(".form-for-new-client").detach();
    }
    return $detached;
  });

  $("#headingTwo").click(function(){
    if($detached){
      $('#cardBody').append($detached);
      $detached = null;
    }
  })
})