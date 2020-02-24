window.dropdownTax;

window.convertCurrency = function(currency) {
  var temp = currency.replace(/[^0-9.-]+/g,"");
  return parseFloat(temp);
}

//Convert number to currency format
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
            "<input type='text' value='" + replaceNumberWithCurrencyFormat(result) + "' class='form-control tax-value' disabled='disabled'>" +
          "</div>" +
        "</div>");
      }
    }
  }
  if ( $("#invoice_line_amount_type").val() === "exclusive" ) {
    result = (amount*(rate/100));
    addElementCalculatedTax(result.toFixed(2));
    var totalTax = 0;
    // Increment the tax value
    $(".calculated-tax").each(function(){
      totalTax += parseFloat($(this).find("input.tax-value").val());
      return totalTax;
    })
    // Add tax + subtotal
    $(".total-calculated").val( totalTax + parseFloat($(".subtotal-calculated").val().replace(/,/g, '')) );
  } else if ( $("#invoice_line_amount_type").val() === "inclusive" ) {
    result = (amount-(amount/((100+rate)/100)));
    addElementCalculatedTax(result.toFixed(2));
    // total = subtotal
    $(".total-calculated").val(  parseFloat($(".subtotal-calculated").val().replace(/,/g, '')) );
  } else {
    $( ".total-tax-row" ).remove();
    $(".total-calculated").val(  parseFloat($(".subtotal-calculated").val().replace(/,/g, '')) );
  }
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
