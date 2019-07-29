function getXeroItem(item_id, field) {
  $.get("/symphony/xero_item_code/"+item_id, function(data) {
    console.log(data);
    $("#invoice_line_items_attributes_"+field+"_description").val(data.item.purchase_description);
    $("#invoice_line_items_attributes_"+field+"_quantity").val(1);
    $("#invoice_line_items_attributes_"+field+"_price").val(data.item.price_code);

    //account
    var selectize_account = $("#invoice_line_items_attributes_"+field+"_account").selectize();
    var selectize_account = selectize_account[0].selectize;
    selectize_account.setValue(data.item.account, false);

    //tax
    var selectize_tax = $("#invoice_line_items_attributes_"+field+"_tax").selectize();
    var selectize_tax = selectize_tax[0].selectize;
    selectize_tax.setValue(data.item.tax, false);
  });
}

$(document).on("turbolinks:load", function(){
  $('form').on('click', '.remove_fields', function(event) {
    $(this).closest('tr').find('.destroy').val('1');
    $(this).closest('tr').hide();
    return event.preventDefault();
  });
  //removing a line_item in the invoice
  $('form').on('click', '.remove_line_items', function(event){
      $(this).closest('tr').find('.destroy').val('1');
      $(this).closest('tr').remove();
      return event.preventDefault();
  })
  //removing a task in template
  $('form').on('click', '.remove_tasks', function(event){
      $(this).prev('input[type=hidden]').val('1');
      $(this).closest('tr').hide();
      return event.preventDefault();
  })

  //General way of adding attribute through link_to_add_row method in application helper
  $('form').on('click', '.add_task_fields', function(event) {
    let regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data('id'), 'g');
    $( '.task-in-section-' + $(this).data('sectionId') ).append($(this).data('fields').replace(regexp, time));
    //Loop section count to get the index of the section's array
    $( ".section-count" ).each(function( index ) {
      $("select[id$='template_sections_attributes_" + index + "_tasks_attributes_" + time + "_task_type']").selectize({
        dropdownParent: "body"
      });
      $("select[id$='template_sections_attributes_" + index + "_tasks_attributes_" + time + "_role_id']").selectize({
        dropdownParent: "body"
      });
      $("select[id$='template_sections_attributes_" + index + "_tasks_attributes_" + time + "_document_template_id']").selectize({
        dropdownParent: "body"
      });
      $('.data-attributes').find('tr:last-child').find('.create').val('1');
    });
    return event.preventDefault();
  });
  //if radio button is checked, disable or enable the relevant fields
  $('input:radio[name="radioContact"]').click(function(){
    if($(this).val() == 'existing'){
      $('.new-disable').attr('disabled', true);
      $('.existing-contact-disable')[0].selectize.enable();
    }
    else{
      $('.existing-contact-disable')[0].selectize.disable();
      $('.new-disable').attr('disabled', false);
    }
  });
  return $('input').change(function(event) {
    return $(this).closest('td').next().find('.update').val('1');
  });
});
