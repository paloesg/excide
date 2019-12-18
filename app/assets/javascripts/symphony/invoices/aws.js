function run_textract(template, workflow){
  $.post("/symphony/"+template+"/"+workflow+"/textract").done((result) => {
    get_document_analysis(template, workflow, result);
  })
}

function get_document_analysis(template, workflow, job_id){
  $.post("/symphony/"+template+"/"+workflow+"/get_textract", job_id).done((result) => {
    window.setTimeout(function() {
      if (result.job_status == "IN_PROGRESS") {
        get_document_analysis(template, workflow, job_id);  
      }
      else {
        console.log(result);
        $('.loading').hide();
        $(".aws-textract-result").text(JSON.stringify(result.blocks));
        return result;
      }
    }, 7000)
  })
}

$(document).on("turbolinks:load", function() {
  $('.do-textract').click(function(){
    let template = $('.template-field').val() ;
    let workflow = $('.workflow-field').val() ;
    run_textract(template, workflow);
    $('.loading').show();
  })
})