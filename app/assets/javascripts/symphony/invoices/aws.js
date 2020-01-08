var xero_accounts = [];
var xero_taxes = [];
var xero_tracking_categories_1 = [];
var xero_items = [];

function get_xero_details(template, workflow){
  $.post("/symphony/"+template+"/"+workflow+"/xero_details", function( data ) {
    $.each(data, function(i, val) {
      if(val.accounts != null){
        $.each(val.accounts, function(i, acc){
          xero_accounts.push({value:acc, text:acc})
        })
      }
      if(val.taxes != null){
        $.each(val.taxes, function(i, tax){
          xero_taxes.push({value:tax[0], text:tax[0], 'data-rate':tax[1]['data-rate']})
        })
      }
      if(val.tracking_categories_1 != null){
        $.each(val.tracking_categories_1, function(i, cat1){
          cat1 = JSON.parse(cat1);
          xero_tracking_categories_1.push({value:cat1["name"], text:cat1["name"], tracking_option_id:cat1["tracking_option_id"]})
        })
      }
      if(val.items != null){
        $.each(val.items, function(i, item){
          xero_items.push({value:item, text:item})
        })
      }
    })
  });
}

function get_document_analysis(template, workflow, job_id){
  $.post("/symphony/"+template+"/"+workflow+"/get_textract", {job_id:job_id}).done((result) => {  
    $('.loading-textract').hide();
    let tables = get_table(result.blocks);
    $(".aws-textract-result").text(JSON.stringify(tables));
    $.each(tables, function(i, table) {
      console.log(table)
      let ids = [];
      $.each(table["result"], function(result_index, result_value) {
        let head_row = {};
        $.each(result_value, function(col_index, col_value) {
          if(col_value.includes("price") || col_value.includes("Price")) {
            head_row["price"] = col_index;
          }
          if(col_value.includes("description") || col_value.includes("Description")) {
            head_row["description"] = col_index;
          }
          if(col_value.includes("amount") || col_value.includes("Amount")) {
            head_row["amount"] = col_index;
          }
          if(col_value.includes("quantity") || col_value.includes("Quantity")) {
            head_row["quantity"] = col_index;
          }
        })
        if(!($.isEmptyObject(head_row))){
          ids.push(head_row);
        }
      })
      let indexArr = [];  
      $.each(table["result"], function(result_index, result_value){ 
        if (ids.length > 0) {
          if(result_index != 1){
            let row_result = {};   
            if(ids[0].description){
              row_result["description"] = result_value[ids[0].description];
            }   
            if(ids[0].price && result_value[ids[0].price]){
              row_result["price"] = result_value[ids[0].price].includes("$") ? result_value[ids[0].price].replace(/([^\w.\s]|(?!\d)\.(?!\d))+/g, '') : result_value[ids[0].price];
            }    
            if(ids[0].amount && result_value[ids[0].amount]){
              row_result["amount"] = result_value[ids[0].amount].includes('$') ? result_value[ids[0].amount].replace(/([^\w.\s]|(?!\d)\.(?!\d))+/g, '') : result_value[ids[0].amount];
            }  
            if(ids[0].quantity){
              row_result["quantity"] = result_value[ids[0].quantity];
            }  
            row_result["index"] = result_index;
            add_line_items(row_result, template, workflow);
            indexArr.push(row_result)
          } 
        }                       
      })
    })
    return tables;
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

function add_line_items(data, template, workflow){
  // Add value to line items
  let items = '<select class="minimize-text line-items-dropdown-width dropdown-items selectized" name="invoice[line_items_attributes]['+data.index+'][item]" id="invoice_line_items_attributes_'+data.index+'_item" tabindex="-1" style="display: none;"><option value="" selected="selected"></option></select>';
  let description = '<input class="form-control minimize-text" type="text" name="invoice[line_items_attributes]['+data.index+'][description]" id="invoice_line_items_attributes_'+data.index+'_description" value='+ ( data.description == null ? "" : data.description) +'>';
  let quantity = '<input class="form-control minimize-text" type="number" name="invoice[line_items_attributes]['+data.index+'][quantity]" id="invoice_line_items_attributes_'+data.index+'_quantity" value='+data.quantity+'>';
  let price = '<input class="form-control minimize-text" type="text" name="invoice[line_items_attributes]['+data.index+'][price]" id="invoice_line_items_attributes_'+data.index+'_price" value='+(data.price == null ? 0 : data.price)+'>';
  let account = '<select class="minimize-text dropdown-overlay line-items-dropdown-width selectized" name="invoice[line_items_attributes]['+data.index+'][account]" id="invoice_line_items_attributes_'+data.index+'_account" tabindex="-1"><option value="" selected="selected"></option></select>';
  let tax = '<select class="minimize-text dropdown-tax line-items-dropdown-width selectized" name="invoice[line_items_attributes]['+data.index+'][tax]" id="invoice_line_items_attributes_'+data.index+'_tax" tabindex="-1" ><option value="" selected="selected"></option></select>';
  let region = '<select class="minimize-text dropdown-overlay selectized" name="invoice[line_items_attributes]['+data.index+'][tracking_option_1]" id="invoice_line_items_attributes_'+data.index+'_tracking_option_1" tabindex="-1" ><option value="" selected="selected"></option></select>';
  let amount = '<input class="form-control minimize-text" readonly="readonly" type="text" name="invoice[line_items_attributes]['+data.index+'][amount]" id="invoice_line_items_attributes_'+data.index+'_amount" value='+(data.amount == null ? 0 : data.amount)+'>';
  let delete_button = '<a class="btn btn-danger remove_line_items" href="#">x</a>';

  // Add field to form
  $(".table tbody").append("<tr><td class='line-item-field'>"+items+"</td><td class='line-item-field'>"+description+"</td><td class='line-item-field'>"+quantity+"</td><td class='line-item-field'>"+price+"</td><td class='line-item-field'>"+account+"</td><td class='line-item-field tax'>"+tax+"</td><td class='line-item-field'>"+region+"</td><td class='line-item-field'>"+amount+"</td><td class='line-item-field pr-2'>"+delete_button+"</td></tr>");

  // Selectize
  $("select[id$='invoice_line_items_attributes_" + data.index + "_item']").selectize({
    dropdownParent: "body",
    options: xero_items
  });
  $("select[id$='invoice_line_items_attributes_" + data.index + "_account']").selectize({
    dropdownParent: "body",
    options: xero_accounts
  });
  $("select[id$='invoice_line_items_attributes_" + data.index + "_tax']").selectize({
    dropdownParent: "body",
    options: xero_taxes
  });
  $("select[id$='invoice_line_items_attributes_" + data.index + "_tracking_option_1']").selectize({
    dropdownParent: "body",
    options: xero_tracking_categories_1
  });
  $("select[id$='invoice_line_items_attributes_" + data.index + "_tracking_option_2']").selectize({
    dropdownParent: "body"
  });  
}

$(document).on("turbolinks:load", function() {
  $('.loading-textract').hide();
  $('.do-textract').click(function(){
    let template = $('.template-field').val() ;
    let workflow = $('.workflow-field').val() ;
    let job_id = $('.textract-job-id-field').val();
    $(".table>tbody>tr").remove();
    get_xero_details(template, workflow);
    get_document_analysis(template, workflow, job_id);
    $('.loading-textract').show();
  })
})