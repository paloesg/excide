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
  // dropdownParent is required to avoid dropdown clipping issue so that the dropdown isn't a child of an element with clipping
  $('.dropdown-overlay').selectize({
      dropdownParent: "body"
  })
  //add attribute fields with selectize drop down (for creating invoice and data entry)
  $('form').on('click', '.add_attribute_fields', function(event) {
    let regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data('id'), 'g');
    $(".table>tbody>tr:last-child").after($(this).data('fields').replace(regexp, time));
    $("select[id$='" + time + "_account']").selectize({
      dropdownParent: "body"
    });
    $("select[id$='" + time + "_tax']").selectize({
      dropdownParent: "body"
    });
    $("select[id$='" + time + "_tracking_option_1']").selectize({
      dropdownParent: "body"
    });
    $("select[id$='" + time + "_tracking_option_2']").selectize({
      dropdownParent: "body"
    });
    $('.data-attributes').find('tr:last-child').find('.create').val('1');
    return event.preventDefault();
  });
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
    //General way of adding attribute through link_to_add_row method in application helper
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
    });
    return event.preventDefault();
  });
  //if radio button is checked, disable or enable the relevant fields
  $('input:radio[name="radioContact"]').click(
    function(){
      if($(this).val() == 'existing'){
        $('.new-disable').attr('disabled', true);
        $('.existing-contact-disable')[0].selectize.enable();
      }
      else{
        $('.existing-contact-disable')[0].selectize.disable();
        $('.new-disable').attr('disabled', false);
      }
    }
  )
  return $('input').change(function(event) {
    return $(this).closest('td').next().find('.update').val('1');
  });
  return event.preventDefault();
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