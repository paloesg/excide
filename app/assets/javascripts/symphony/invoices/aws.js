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
        $('.loading').hide();
        let table = get_table(result.blocks);
        $(".aws-textract-result").text(JSON.stringify(table));
        return table;
      }
    }, 7000)
  })
}

function get_table(data) {
  blocks_map = {};
  table_blocks = [];
  table_result = [];
  $.each(data, function(i, block) {
    blocks_map[block.id] = block;
    if (block.block_type == "TABLE") {
      table_blocks.push(block);
    }
  })
  $.each(table_blocks, function(i, table){
    result = get_rows_columns(table, blocks_map);
    table_result.push({"table_index" : i, result});
  })
  return table_result;
}

function get_rows_columns(table, data) {
  rows = {};
  $.each(table.relationships, function(i, relationship){
    if(relationship.type == "CHILD"){
      $.each(relationship.ids, function(i, child) {
        let cell = data[child];
        if (cell.block_type == "CELL") {
          row_index = cell.row_index;
          col_index = cell.column_index;
          if(!(row_index in rows)) {
            rows[row_index] = {};
          }
          rows[row_index][col_index] = get_text(cell, data);
        }
      })
    }
  })
  return rows;
}

function get_text(cell, data){
  text= '';
  if(cell.relationships){
    $.each(cell.relationships, function(i, relationship) {
      if(relationship.type == "CHILD"){
        $.each(relationship.ids, function(i, child){
          let word = data[child];
          if(word.block_type == "WORD"){
            text += word.text;
          }
          if(word.block_type == "SELECTION_ELEMENT"){
            if (word.selection_status == "SELECTED"){
              text += 'X ';
            }
          }
        })
      }
    })
  }
  return text;
}

$(document).on("turbolinks:load", function() {
  $('.loading').hide();
  $('.do-textract').click(function(){
    let template = $('.template-field').val() ;
    let workflow = $('.workflow-field').val() ;
    run_textract(template, workflow);
    $('.loading').show();
  })
})