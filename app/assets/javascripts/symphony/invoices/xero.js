function getXeroItem(item_id, field) {
  $('.loading').show();
  $.get("/symphony/xero_item_code/"+item_id, function(data) {
    $("#invoice_line_items_attributes_"+field+"_description").val(data.item.purchase_description);
    $("#invoice_line_items_attributes_"+field+"_quantity").val(1);
    $("#invoice_line_items_attributes_"+field+"_price").val(data.item.price_code);

    //selectize account
    var selectize_account = $("#invoice_line_items_attributes_"+field+"_account").selectize();
    var selectize_account = selectize_account[0].selectize;
    selectize_account.setValue(data.item.account, false);

    //selectize tax
    var selectize_tax = $("#invoice_line_items_attributes_"+field+"_tax").selectize();
    var selectize_tax = selectize_tax[0].selectize;
    selectize_tax.setValue(data.item.tax, false);

    window.setTimeout(function() {
      $('.loading').hide();
    }, 50);
  });
}

$(document).on("turbolinks:load", function(){
  $('.loading').hide();
  // dropdownParent is required to avoid dropdown clipping issue so that the dropdown isn't a child of an element with clipping
  $('.dropdown-overlay').selectize({
    dropdownParent: "body"
  })

  $(".dropdown-items").selectize({
    dropdownParent: "body",
    onChange: function(value) {
      let obj = $(this)[0];
      let item_id = value.split(": ")[0];
      let this_id = (obj.$input["0"].id).split('_')[4]
      getXeroItem(item_id, this_id);
    }
  });

  //add attribute fields with selectize drop down (for creating invoice and data entry)
  $('form').on('click', '.add_attribute_fields', function(event) {
    let regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data('id'), 'g');
    $(".table>tbody>tr:last-child").after($(this).data('fields').replace(regexp, time));
    $("select[id$='" + time + "_item']").selectize({
      dropdownParent: "body",
      onChange: function(value) {
        let item_id = value.split(": ")[0];
        getXeroItem(item_id, time);
      }
    });
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
})