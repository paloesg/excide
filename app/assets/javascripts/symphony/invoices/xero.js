function getXeroItem(itemCode, field) {
  $(".loading").show();
  $.get("/symphony/xero_item_code", { "item_code": itemCode })
  .done(function(data) {
    $("#invoice_line_items_attributes_"+field+"_description").val(data.purchase_description);
    $("#invoice_line_items_attributes_"+field+"_quantity").val(1);
    $("#invoice_line_items_attributes_"+field+"_price").val(data.sales_details.unit_price);
    $("#invoice_line_items_attributes_"+field+"_amount").val(1*data.sales_details.unit_price);
    $("input#subtotal").val( calculateSubtotal() );

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

// Automatically calculate the amount field
function calculateAmount() {
  $("input[id$='_quantity'], input[id$='_price']").change(function () {
    quantity = $(this).closest(".line_items").find("input[id$='_quantity']").val();
    price = $(this).closest(".line_items").find("input[id$='_price']").val();
    amount = $(this).closest(".line_items").find("input[id$='_amount']");
    amount.val( (quantity*price).toFixed(2) );
    $("input#subtotal").val( calculateSubtotal() );
  })
}

// Automatically calculate the subtotal field
function calculateSubtotal() {
  sum = 0;
  amounts = $("input[id$='_amount']");
  amounts.each(function(index, field) {
      sum += Number($(field).val());
  });
  return sum.toFixed(2);
}

// Calculate total tax
function calculateTotalTax(amount, rate) {
  amount = parseFloat(amount);
  rate = parseFloat(rate);
  if ( $("#invoice_line_amount_type").val() == "exclusive" ) {
    $("#subtotal-wrapper").append("<div class='form-row'>"+
      "<div class='form-inline col-auto ml-auto mb-2 pull-right'>" +
        "<label class='mr-2'> Total tax "+  rate + "%  </label>" +
        "<input type='number' value='" + (amount*(rate/100)).toFixed(2) + "' class='form-control form-control-sm' disabled='disabled'>" +
      "</div>" +
    "</div>")
  } else if ( $("#invoice_line_amount_type").val() == "inclusive" ) {
    $("#subtotal-wrapper").append("<div class='form-row'>"+
      "<div class='form-inline col-auto ml-auto mb-2 pull-right'>" +
        "<label class='mr-2'> Total tax "+  rate + "%  </label>" +
        "<input type='number' value='" + (amount-(amount/((100+rate)/100))).toFixed(2) + "' class='form-control form-control-sm' disabled='disabled'>" +
      "</div>" +
    "</div>")
  }
}

$(document).on("turbolinks:load", function(){
  $(".loading").hide();
  // dropdownParent is required to avoid dropdown clipping issue so that the dropdown isn't a child of an element with clipping
  $(".dropdown-overlay").selectize({
    dropdownParent: "body"
  })

  $(".dropdown-tax").selectize({
    onInitialize: function () {
      var s = this;
      var currentAmount = this.$wrapper.closest("tr.line_items").find("input[id$='_amount']").val();
      // Get selected tax
      currentTaxRate = $.grep(this.revertSettings.$children, function(a) {
        return a['defaultSelected'];
      })
      // console.log(currentTaxRate)
      if (currentTaxRate.length) {
        taxRate = currentTaxRate[0]['dataset']['rate'];
        calculateTotalTax(currentAmount, taxRate);
      }
      this.revertSettings.$children.each(function () {
        $.extend(s.options[this.value], $(this).data());
      });
    },
    onChange: function (value) {
      var t = this
      $(".tax > div > .has-items > .item").each(function(index, item) {
        itemValue = $(item).text();
        itemRate = t.options[itemValue].rate;
        itemAmount = $(item).closest(".line_items").find("input[id$='_amount']").val();
        calculateTotalTax(itemAmount, itemRate);
      })
    }
  });

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

  // Run calculate after the page is loaded
  calculateAmount();
  $("input#subtotal").val( calculateSubtotal() );

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
    calculateAmount();
    return event.preventDefault();
  });
});