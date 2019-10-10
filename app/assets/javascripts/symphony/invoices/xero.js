function getXeroItem(itemCode, field) {
  $(".loading").show();
  $.get("/symphony/xero_item_code", { "item_code": itemCode })
  .done(function(data) {
    $("#invoice_line_items_attributes_"+field+"_description").val(data.purchase_description);
    $("#invoice_line_items_attributes_"+field+"_quantity").val(1);
    $("#invoice_line_items_attributes_"+field+"_price").val(data.sales_details.unit_price);

    //selectize account
    if (data.sales_details.account_code) {
      let selectizeAccount = $("#invoice_line_items_attributes_"+field+"_account").selectize();
      selectizeAccount = selectizeAccount[0].selectize;
      let accOptions = selectizeAccount.options;
      $.map(accOptions, function (accOpt) {
        let txtOpt = accOpt.text.split(" - ");
        if (txtOpt[0] === data.sales_details.account_code) {
          // set selected option
          selectizeAccount.setValue(accOpt.text);
        }
      });
    }

    //selectize tax
    if (data.sales_details.tax_type) {
      let selectizeTax = $("#invoice_line_items_attributes_"+field+"_tax").selectize();
      selectizeTax = selectizeTax[0].selectize;
      let taxOptions = selectizeTax.options;
      $.map(taxOptions, function (taxOpt) {
        let txtOpt = taxOpt.text.split(" - ");
        if (txtOpt[txtOpt.length-1] === data.sales_details.tax_type) {
          // set selected option
          selectizeTax.setValue(taxOpt.text);
        }
      });
    }
  })
  .fail(function() {
    alert( "error" );
  })
  .always(function() {
    window.setTimeout(function() {
      $(".loading").hide();
    }, 5);
  });
}

$(document).on("turbolinks:load", function(){
  $(".loading").hide();
  // dropdownParent is required to avoid dropdown clipping issue so that the dropdown isn't a child of an element with clipping
  $(".dropdown-overlay").selectize({
    dropdownParent: "body"
  })

  $(".dropdown-items").selectize({
    dropdownParent: "body",
    onChange: function(value) {
      let obj = $(this)[0];
      let itemCode = value.split(": ")[0];
      let thisId = (obj.$input["0"].id).split("_")[4];
      getXeroItem(itemCode, thisId);
    }
  });

  //Disable the send xero button when form is changed
  $("form").on("change", function(){
    //disable submit approval button
    $(".submit-approval-button").addClass("disabled");
    //disable approve button
    $(".approve-button").addClass("disabled");
  });

  $("input[id$='_quantity'], input[id$='_price']").change(function () {
    quantity = $(this).closest(".line_items").find("input[id$='_quantity']").val();
    price = $(this).closest(".line_items").find("input[id$='_price']").val();
    amount = $(this).closest(".line_items").find("input[id$='_amount']");
    amount.val( (quantity*price).toFixed(2) );
  })

  //add attribute fields with selectize drop down (for creating invoice and data entry)
  $("form").on("click", ".add_attribute_fields", function(event) {
    let regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data("id"), "g");
    $(".table>tbody>tr:last-child").after($(this).data("fields").replace(regexp, time));
    $("select[id$='" + time + "_item']").selectize({
      dropdownParent: "body",
      onChange: function(value) {
        let itemCode = value.split(": ")[0];
        getXeroItem(itemCode, time);
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
    $(".data-attributes").find("tr:last-child").find(".create").val("1");
    return event.preventDefault();
  });
});