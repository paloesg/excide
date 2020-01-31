
window.convertCurrency = function(currency) {
  var temp = currency.replace(/[^0-9.-]+/g,"");
  return parseFloat(temp);
}

//convert number to currency format
window.replaceNumberWithCurrencyFormat = function(num) {
  return parseFloat(num).toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,");
}

// Automatically calculate the subtotal field
window.calculateSubtotal = function() {
  let sum = 0;
  let amounts = $("input[id$='_amount']");
  amounts.each(function(index, field) {
      sum += Number(convertCurrency($( field).val()));
  });
  return sum ? sum.toFixed(2) : 0;
}

// Calculate total tax & append element
window.calculateTotalTax = function(amount, rate) {
  amount = convertCurrency(amount);
  amount = parseFloat(amount);
  rate = parseFloat(rate);
  let result = 0.0;

  function addElementCalculatedTax(result) {
    let getExistRate = $(".total-tax-row[data-rate='"+rate+"']");
    if (getExistRate.length) {
      // Combine tax depend by value of tax rate
      let value = getExistRate.first().find("input").val();
      let combine = parseFloat(value) + parseFloat(result);
      if (combine) { // Result of combine should be a number
        getExistRate.first().find("input").val(combine.toFixed(2));
      }
    } else {
      if (rate !== 0) { // Dont display calculated tax rate is `0.00%`
        $("#subtotal-wrapper").append("<div class='form-row total-tax-row calculated-tax' data-rate='"+rate+"'>"+
          "<div class='form-inline col-auto ml-auto mb-2 pull-right'>" +
            "<label class='mr-2'> Total tax "+ rate + "%  </label>" +
            "<input type='text' value='" + replaceNumberWithCurrencyFormat(result) + "' class='form-control' disabled='disabled'>" +
          "</div>" +
        "</div>");
      }
    }
  }

  if ( $("#invoice_line_amount_type").val() === "exclusive" ) {
    result = (amount*(rate/100)).toFixed(2);
    addElementCalculatedTax(result);
  } else if ( $("#invoice_line_amount_type").val() === "inclusive" ) {
    result = (amount-(amount/((100+rate)/100))).toFixed(2);
    addElementCalculatedTax(result);
  } else {
    $( ".total-tax-row" ).remove();
  }
}

window.updateTotalTax = function() {
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

// Automatically calculate the amount field
window.calculateAmount = function() {
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

// Convert currency to number when form do submit
window.convertNormalNumber = function(){
  let amounts = $("input[id$='_amount']");
  amounts.each(function(index, field) {
    $( field).val(convertCurrency($( field).val()));
  });

  let prices = $("input[id$='_price']");
  prices.each(function(index, field) {
    $( field).val(convertCurrency($( field).val()));
  });

  $("input#subtotal").val(convertCurrency($("input#subtotal").val()));
  $("input#invoice_total").val(convertCurrency($("input#invoice_total").val()));
}