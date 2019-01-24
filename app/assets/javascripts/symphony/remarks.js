$( document ).ajaxSuccess(function( event, xhr, settings ) {
    console.log("XHR IS: ", xhr.responseText);
    var data = xhr.responseText;
    var jsonData = JSON.parse(data);
    console.log("the JSON data is: ", jsonData);
    $("#check-" + jsonData.id).show().fadeTo(500, 200, function(){
        $("#check-" + jsonData.id).fadeTo(200, 0);
    });
    $("#remarks-" + jsonData.id).text(jsonData.remarks);
});