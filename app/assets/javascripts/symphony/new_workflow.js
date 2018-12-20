$(document).ready(function(){
    //var clone = $(".form-for-new-client").clone();
    var $detached = true;
    $detached = $(".form-for-new-client").detach();

    $(".existing-client-header").click(function(){
        if ( $detached ) {
            $("#headingTwo").click(function(){
                // console.log("APPEND!");
                $('#cardBody').append($detached);
                $detached = null;
            })
        }
        else{
            $detached = $(".form-for-new-client").detach();
            // console.log("DETACHED!!");
        }
        // console.log("Final part!");
        // $detached = $(".form-for-new-client").detach();
        return $detached;
    });

    $("#headingTwo").click(function(){
        if($detached){
            // console.log("SECOND APPEND!!");
            $('#cardBody').append($detached);
            $detached = null;
        }
    })
})