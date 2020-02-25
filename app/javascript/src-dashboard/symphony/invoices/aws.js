/*global moment, dropdownTax, convertCurrency, replaceNumberWithCurrencyFormat, calculateTotalTax, calculateSubtotal a*/
/*eslint no-undef: "error"*/

var xeroAccounts = [];
var xeroTaxes = [];
var xeroTrackingCategories1 = [];
var xeroItems = [];

// Get Accounts, Taxes, Tracking, Items from xero
function getXeroDetails(template, workflow){
  $.post("/symphony/"+template+"/"+workflow+"/xero_details", function( data ) {
    $.each(data, function(i, val) {
      if(val.accounts !== null){
        $.each(val.accounts, function(i, acc){
          xeroAccounts.push({value:acc, text:acc});
        })
      }
      if(val.taxes !== null){
        $.each(val.taxes, function(i, tax){
          xeroTaxes.push({value:tax[0], text:tax[0], 'data-rate':tax[1]['data-rate']});
        })
      }
      if(val.tracking_categories_1 !== null){
        $.each(val.tracking_categories_1, function(i, cat1){
          cat1 = JSON.parse(cat1);
          xeroTrackingCategories1.push({"value":cat1["name"], "text":cat1["name"], "tracking_option_id":cat1["tracking_option_id"]});
        })
      }
      if(val.items !== null){
        $.each(val.items, function(i, item){
          xeroItems.push({value:item, text:item});
        })
      }
    })
  });
}

function addValueToFieldLineItems(data){ 
  // Add value to line item fields
  let items = '<select class="minimize-text line-items-dropdown-width dropdown-items selectized" name="invoice[line_items_attributes]['+data.index+'][item]" id="invoice_line_items_attributes_'+data.index+'_item" tabindex="-1" style="display: none;"><option value="" selected="selected"></option></select>';
  let description = '<input class="form-control minimize-text" type="text" name="invoice[line_items_attributes]['+data.index+'][description]" id="invoice_line_items_attributes_'+data.index+'_description" value="' + ( data.description ?  data.description : "") +'">';
  let quantity = '<input class="form-control minimize-text" type="number" name="invoice[line_items_attributes]['+data.index+'][quantity]" id="invoice_line_items_attributes_'+data.index+'_quantity" value='+data.quantity+'>';
  let price = '<input class="form-control minimize-text" type="text" name="invoice[line_items_attributes]['+data.index+'][price]" id="invoice_line_items_attributes_'+data.index+'_price" value='+(data.price ? data.price : 0)+'>';
  let account = '<select class="minimize-text dropdown-overlay line-items-dropdown-width selectized" name="invoice[line_items_attributes]['+data.index+'][account]" id="invoice_line_items_attributes_'+data.index+'_account" tabindex="-1"><option value="" selected="selected"></option></select>';
  let tax = '<select class="minimize-text dropdown-tax line-items-dropdown-width selectized" name="invoice[line_items_attributes]['+data.index+'][tax]" id="invoice_line_items_attributes_'+data.index+'_tax" tabindex="-1" ><option value="" selected="selected"></option></select>';
  let region = '<select class="minimize-text dropdown-overlay selectized" name="invoice[line_items_attributes]['+data.index+'][tracking_option_1]" id="invoice_line_items_attributes_'+data.index+'_tracking_option_1" tabindex="-1" ><option value="" selected="selected"></option></select>';
  let amount = '<input class="form-control minimize-text amount-data" readonly="readonly" type="text" name="invoice[line_items_attributes]['+data.index+'][amount]" id="invoice_line_items_attributes_'+data.index+'_amount" value='+(data.amount ? data.amount : 0)+'>';
  let deleteButton = '<a class="btn btn-danger remove_line_items" href="#">x</a>';

  // Add fields to form
  $(".table tbody").append("<tr class='line_items'><td class='line-item-field'>"+items+"</td><td class='line-item-field'>"+description+"</td><td class='line-item-field'>"+quantity+"</td><td class='line-item-field'>"+price+"</td><td class='line-item-field'>"+account+"</td><td class='line-item-field tax'>"+tax+"</td><td class='line-item-field'>"+region+"</td><td class='line-item-field amount'>"+amount+"</td><td class='line-item-field pr-2'>"+deleteButton+"</td></tr>");
}

function addLineItems(data){
  function calculateAmount() {
    $("input[id$='_quantity'], input[id$='_price']").change(function () {
      let quantity = $(this).closest(".line_items").find("input[id$='_quantity']").val();
      let inputPrice = $(this).closest(".line_items").find("input[id$='_price']");
      let amount = $(this).closest(".line_items").find("input[id$='_amount']");
      let inputTax = $(this).closest(".line_items").find("select[id$='_tax']");
      let price = inputPrice.val() ? convertCurrency(inputPrice.val()) : 0;
      amount.val(price === 0? 0 : quantity*price);
      $("input#subtotal").val( replaceNumberWithCurrencyFormat(calculateSubtotal()) );

      $(".tax > div > .has-items > .item").each(function(index, item) {
        let itemRate = parseFloat(inputTax.options[$(item).text()]['data-rate']);
        let itemAmount = amount.val();
        calculateTotalTax(itemAmount.toString(), itemRate.toString());
      })
      //replace to currency format
      amount.val(replaceNumberWithCurrencyFormat(amount.val()));
      inputPrice.val(replaceNumberWithCurrencyFormat(price));
    })
  }

  addValueToFieldLineItems(data);

  // Selectize for Line Items
  $("select[id$='invoice_line_items_attributes_" + data.index + "_item']").selectize({
    dropdownParent: "body",
    options: xeroItems
  });

  // Selectize for Account
  $("select[id$='invoice_line_items_attributes_" + data.index + "_account']").selectize({
    dropdownParent: "body",
    options: xeroAccounts
  });
  
  // Selectize for Tax
  $("select[id='invoice_line_items_attributes_" + data.index + "_tax']").selectize({
    dropdownParent: "body",
    options: xeroTaxes,
    onInitialize() {
      var s = this;
      var currentAmount = this.$wrapper.closest("tr.line_items").find("input[id='invoice_line_items_attributes_"+data.index+"_amount']").val();
      // Get selected tax
      let currentTaxRate = $.grep(this.revertSettings.$children, function(a) {
        return a["defaultSelected"];
      })
      if (currentTaxRate.length) {
        let taxRate = currentTaxRate[0]["dataset"]["data-rate"];
        calculateTotalTax(currentAmount, taxRate);
      }
      this.revertSettings.$children.each(function () {
        $.extend(s.options[this.value], $(this).data());
      });
    },
    onChange() {
      var t = this;
      $( ".total-tax-row" ).remove();
      $(".tax > div > .has-items > .item").each(function(index, item) {
        let itemRate = parseFloat(t.options[$(item).text()]['data-rate']);
        let itemAmount = parseFloat($(item).closest('.line-item-field.tax').siblings('.line-item-field.amount').children(".amount-data").val());
        calculateTotalTax(itemAmount.toString(), itemRate.toString());
      })
      $("select#invoice_line_amount_type").attr("disabled", "disabled");
    }
  });

  // Selectize for Tracking option 1
  $("select[id$='invoice_line_items_attributes_" + data.index + "_tracking_option_1']").selectize({
    dropdownParent: "body",
    options: xeroTrackingCategories1
  });

  $("input[id$='_price']").keydown(function (event) {
    // Check if tab keyboard button pressed
    if (event.keyCode === 9) {
      calculateAmount();
    }
  });
  calculateAmount();
}

function formatDate(dateStr){
  dateStr = dateStr.replace(/(^\s+|[^a-zA-Z0-9 ]+|\s+$)/g,"-");
  dateStr = dateStr.replace(/\s+/g, "-");
  //put the date to array
  var dsplit = dateStr.split("-");

  // if year cannot detect, default year is current year
  if (!dsplit[2]){
    dsplit[2] = new Date().getFullYear();
  }
  // Check for the condition that the year is only displayed in 2 numbers (eg 11-02-19). For that, we manually prepend '20' to the date
  else if(dsplit[2].length < 4){
    dsplit[2] = dsplit[2].replace (/^/,'20');
  }
  // create the date
  var d = new Date(dsplit[2],dsplit[1]-1,dsplit[0]);

  //if cannot get the date it will run create new date again with other format, because sometimes user input month with text, for example: "20 Aug"
  if (d === "Invalid Date"){
    dateStr = dsplit.join();
    d = new Date(dateStr);
    //if cannot get the date again, the default is today
    if (d === "Invalid Date"){
      d = new Date();
    }
  }
  //format date "20 Aug 2019"
  d = moment(d).format("D MMM YYYY");
  return d;
}

function matchTotal(){
  $("input.total-calculated").change(function(){
    // Check if total inputed by user is the same as total extracted from textract and check that textract total exists
    if ( $(".total-calculated").val() !==  $(".textract-total-value").val() ){
      $(".textract-total-message").removeClass("d-none");
      $("input#invoice_total").css({ border: "1px solid #dc3545" });
    } else{
      $(".textract-total-message").addClass("d-none");
      $("input#invoice_total").css({ border: "1px solid #6fb497" });
    }
  });
}

// Get Document Analist from textract controller
function getDocumentAnalysis(template, workflow){
  $.post("/symphony/"+template+"/"+workflow+"/get_textract").done((result) => {
    $('.loading-textract').hide();
    // Show json result to input textarea
    $(".aws-textract-result").text(JSON.stringify(result["table"]));
    // Validate result when success true and tables not null
    if(result["table"]["success?"] === true && result["table"]["tables"].length > 0){
      $(".table>tbody>tr").remove();
      let tables = result["table"]["tables"];
      let forms = result["table"]["forms"];
      $.each(forms, function(i, form){
        // Used the match() method to search for string and for case insensitive search
        if(Object.keys(form).toString().match(/Invoice Date/i)) {
          $('#datetimepicker1').val(formatDate(Object.values(form).toString().trim()));
        }
        else if(Object.keys(form).toString().match(/Due Date/i)){
          $('#datetimepicker3').val(formatDate(Object.values(form).toString().trim()));
        }
        else if(Object.keys(form).toString().match(/Invoice No./i) || Object.keys(form).toString().match(/Reference No./i) || Object.keys(form).toString().match(/Inv No./i)){
          $('.inv-reference').val(Object.values(form).toString().trim());
        }
        else if(Object.keys(form).toString().match(/Total/i)){
          // Trim white spaces
          $(".textract-total-value").val(Object.values(form).toString().trim().replace(/,/g, ''));
          $('.textract-total').show();
        }
      })
      $.each(tables, function(i, table){
        addLineItems(table);
      })
      $("input#subtotal").val(replaceNumberWithCurrencyFormat(calculateSubtotal()));
      matchTotal();
    }else{
      alert("Unable to extract data from the file automatically. Please manually enter the data or refresh to try again.");
    }
  })
}


$(document).on("turbolinks:load", function() {
  $('.loading-textract').hide();
  $('.textract-total').hide();

  // Run textract when click button extract data
  $('.do-textract').click(function(){
    $('.textract-total').hide();
    $('.total-tax-row' ).remove();
    let template = $('.template-field').val() ;
    let workflow = $('.workflow-field').val() ;
    getXeroDetails(template, workflow);
    getDocumentAnalysis(template, workflow);
    $('.loading-textract').show();
  });

  $('form#new_invoice').on('submit', function () {
    // enable the select dropdown so that database can update the value
    $(this).find('select#invoice_line_amount_type').prop('disabled', false);
  });
});
