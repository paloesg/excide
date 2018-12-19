$(document).ready(function(){
    $(".existing-client").change(function(){
        // console.log("JQUERY WORKS!");
        $("#form-for-new-client").remove();
        // console.log("Value has changed!", value);
    });
});