$(document).on("turbolinks:load", function(){
  $("form").on('change', ':checkbox', function(){
    if ($(".create-batch:checked").length === 0){
     $(".create-batch-through-documents").addClass('d-none');
    }
    else{
     $(".create-batch-through-documents").removeClass('d-none');
    }
  });
});
