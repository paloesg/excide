function getXeroItem(itemCode, field) {
  $(".loading").show();
  $.get("/symphony/xero_line_items", { "item_code": itemCode })
  .done(function(data) {
    $("#invoice_line_items_attributes_"+field+"_description").val(data.description);
    $("#invoice_line_items_attributes_"+field+"_quantity").val(1);
    $("#invoice_line_items_attributes_"+field+"_price").val(data.price);
    $("#invoice_line_items_attributes_"+field+"_amount").val(1*data.price);
    $("input#subtotal").val( replaceNumberWithCurrencyFormat(calculateSubtotal()) );

    //selectize account
    if (data.account) {
      let selectizeAccount = $("#invoice_line_items_attributes_"+field+"_account").selectize();
      selectizeAccount = selectizeAccount[0].selectize;
      let accOptions = selectizeAccount.options;
      $.map(accOptions, function (accOpt) {
        let txtOpt = accOpt.text.split(" - ");
        if (txtOpt[0] === data.account) {
          // set selected option
          selectizeAccount.setValue(accOpt.text);
        }
      });
    }

    //selectize tax
    if (data.tax) {
      let selectizeTax = $("#invoice_line_items_attributes_"+field+"_tax").selectize();
      selectizeTax = selectizeTax[0].selectize;
      let taxOptions = selectizeTax.options;
      $.map(taxOptions, function (taxOpt) {
        let txtOpt = taxOpt.text.split(" - ");
        if (txtOpt[txtOpt.length-1] === data.tax) {
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

var dropdownTax;

$(document).on("turbolinks:load", function(){
  $(".loading").hide();
  // dropdownParent is required to avoid dropdown clipping issue so that the dropdown isn't a child of an element with clipping
  $(".dropdown-overlay").selectize({
    dropdownParent: "body"
  })

  function updateTotalTax() {
    $( ".total-tax-row" ).remove();
    dropdownTax.each(function(index, item) {
      let selectizeItem = dropdownTax.selectize()[parseInt(index)].selectize;
      let currentTaxRate = $.grep(selectizeItem.revertSettings.$children, function(a) {
        let thisValue = $(item).closest("tr.line_items").find(".tax > div > .has-items > .item");
        return a["innerText"] === thisValue.text();
      })
      let dontDestroyLineItem = ($(item).closest("tr.line_items").find("input.destroy").val()!=="1");
      // Check tax field has value & status of the line item is not destroyed & value not empty
      if (currentTaxRate.length && dontDestroyLineItem && currentTaxRate[0]["value"]!=="") {
        let taxRate = currentTaxRate[0]["dataset"]["rate"];
        let currentAmount = selectizeItem.$wrapper.closest("tr.line_items").find("input[id$='_amount']").val();
        calculateTotalTax(currentAmount, taxRate);
      }
    })
  }

  function calculateAmount() {
    $("input[id$='_quantity'], input[id$='_price']").change(function () {
      let quantity = $(this).closest(".line_items").find("input[id$='_quantity']").val();
      let inputPrice = $(this).closest(".line_items").find("input[id$='_price']");
      let amount = $(this).closest(".line_items").find("input[id$='_amount']");
      let price = inputPrice.val() ? convertCurrency(inputPrice.val()) : 0;
      amount.val(price === 0? 0 : quantity*price);
      $("input#subtotal").val( replaceNumberWithCurrencyFormat(calculateSubtotal()) );
      updateTotalTax();
      //replace to currency format
      amount.val(replaceNumberWithCurrencyFormat(amount.val()));
      inputPrice.val(replaceNumberWithCurrencyFormat(price));
    })
  }

  $("#invoice_line_amount_type").change(function() {
    updateTotalTax();
  });

  $("form").on("click", ".remove_line_items", function(){
    updateTotalTax();
  });

  $("input[id$='_price']").keydown(function (event) {
    // check if tab keyboard button pressed
    if (event.keyCode === 9) {
      calculateAmount();
    }
  });

  dropdownTax = $(".dropdown-tax").selectize({
    onInitialize() {
      var s = this;
      var currentAmount = this.$wrapper.closest("tr.line_items").find("input[id$='_amount']").val();
      // Get selected tax
      let currentTaxRate = $.grep(this.revertSettings.$children, function(a) {
        return a["defaultSelected"];
      })
      if (currentTaxRate.length) {
        let taxRate = currentTaxRate[0]["dataset"]["rate"];
        calculateTotalTax(currentAmount, taxRate);
      }
      this.revertSettings.$children.each(function () {
        $.extend(s.options[this.value], $(this).data());
      });
    },
    onChange: function (value) {
      var t = this;
      $( ".total-tax-row" ).remove();
      $(".tax > div > .has-items > .item").each(function(index, item) {
        let itemRate = t.options[$(item).text()].rate;
        let itemAmount = $(item).closest(".line_items").find("input[id$='_amount']").val();
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
  $("input#subtotal").val(replaceNumberWithCurrencyFormat(calculateSubtotal()));

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
    // Add tax selectize object into array of dropdownTax
    dropdownTax.push($("select[id$='" + time + "_tax']").selectize({
      dropdownParent: "body",
      onInitialize() {
        var s = this;
        var currentAmount = this.$wrapper.closest("tr.line_items").find("input[id$='_amount']").val();
        // Get selected tax
        let currentTaxRate = $.grep(this.revertSettings.$children, function(a) {
          return a["defaultSelected"];
        })
        if (currentTaxRate.length) {
          let taxRate = currentTaxRate[0]["dataset"]["rate"];
          calculateTotalTax(currentAmount, taxRate);
        }
        this.revertSettings.$children.each(function () {
          $.extend(s.options[this.value], $(this).data());
        });
      },
      onChange: function (value) {
        var t = this;
        $( ".total-tax-row" ).remove();
        $(".tax > div > .has-items > .item").each(function(index, item) {
          let itemRate = t.options[$(item).text()].rate;
          let itemAmount = $(item).closest(".line_items").find("input[id$='_amount']").val();
          calculateTotalTax(itemAmount, itemRate);
        })
      }
    })[0]);
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

  // if line items amount have value, convert to currency format
  let amounts = $("input[id$='_amount']");
  if(amounts.length > 0){
    amounts.each(function(index, field) {
      if($(field). val()){
        $( field).val(replaceNumberWithCurrencyFormat($( field).val()));
      }
    });
  }

  // if line items price have value, convert to currency format
  let prices = $("input[id$='_price']");
  if(prices.length > 0){
    prices.each(function(index, field) {
      if($(field). val()){
        $( field).val(replaceNumberWithCurrencyFormat($( field).val()));
      }
    });
  }

  $("input#invoice_total").change(function(){
    if($("input#invoice_total").val() !== ""){
      $("input#invoice_total").val(replaceNumberWithCurrencyFormat($("input#invoice_total").val()));
    }
    else {
      $("input#invoice_total").val(0);
    }
  })

  $("form.edit_invoice").submit(function() {
    convertNormalNumber();
  });

  $("form.new_invoice").submit(function() {
    convertNormalNumber();
  });

  
});
