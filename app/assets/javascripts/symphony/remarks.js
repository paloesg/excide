$( document ).ajaxSuccess(function( event, xhr, settings ) {
    var data = xhr.responseText;
    var jsonData = JSON.parse(data);
    $("#check-" + jsonData.id).show().fadeTo(500, 200, function(){
        $("#check-" + jsonData.id).fadeTo(200, 0);
    });
    $("#remarks-" + jsonData.id).text(jsonData.remarks);
});