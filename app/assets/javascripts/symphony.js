//javascript
(function() {
  jQuery(function() {
    $('form').on('click', '.remove_fields', function(event) {
      if ($(this).closest('tr').find('.account-field').length) {
        $(".add_account").removeClass("disabled");
      }
      $(this).closest('tr').find('.destroy').val('1');
      $(this).closest('tr').hide();
      return event.preventDefault();
    });
    //removing a lineitem in the invoice
    $('form').on('click', '.remove_lineitems', function(event){
        $(this).closest('tr').find('.destroy').val('1');
        $(this).closest('tr').remove();
        return event.preventDefault();
    })
    //manually add selectize to the various dropdowns in invoice FORM page
    $('#invoice_line_amount_types, #invoice_lineitems_attributes_0_account, #invoice_lineitems_attributes_0_tax').each(function(){
        $(this).selectize({
            dropdownParent: "body"
        })
    })
    //add attribute fields with selectize drop down (for creating invoice and data entry)
    $('form').on('click', '.add_attribute_fields', function(event) {
      var regexp, time;
      time = new Date().getTime();
      regexp = new RegExp($(this).data('id'), 'g');
      $(".table>tbody>tr:last-child").after($(this).data('fields').replace(regexp, time));
      if ($("input[id$='" + time + "_name']").val() !== "Account") {
        $("input[id$='" + time + "_name']").removeAttr('readonly');
        $("select[id$='" + time + "_account']").selectize({
          dropdownParent: "body"
        });
        $("select[id$='" + time + "_tax']").selectize({
          dropdownParent: "body"
        });
      } else {
        $(".add_account").addClass("disabled");
        $("select[id$='" + time + "_value']").selectize({
          dropdownParent: "body"
        });
      }
      $('.data-attributes').find('tr:last-child').find('.create').val('1');
      return event.preventDefault();
    });
    return $('input').change(function(event) {
      return $(this).closest('td').next().find('.update').val('1');
    });
  });

}).call(this);