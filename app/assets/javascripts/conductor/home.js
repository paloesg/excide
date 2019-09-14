// Show message validation in popover when creating activation
$(document).on("ajax:error", "form", function (xhr, status, error) {
  $(this).find('#popover_validation').text('')
  data = JSON.parse(status.responseText)
  let message, results;
  if (data) {
    results = [];
    for (let message in data) {
      results.push($(this).find('#popover_validation').prepend(' *' + message.replace(/_/g, ' ') + ' ' + data[message]));
    }
    $(this).find('.alert').show()
  }
});
$(document).on("turbolinks:load", function(){
  // Create new activation
  $('.new_activations').popover({
    html: true,
    sanitize: false,
    container: 'body',
    placement: 'auto',
    content: function () {
      return $('#new-activation').html();
    }
  }).on('shown.bs.popover', function () {
    datetimepickers = $('.datetimepicker')
    // get last of .datetimepicker
    datetimepickers.eq(datetimepickers.length - 1).attr('id', 'newdatetimepicker')
    datetimepickers.eq(datetimepickers.length - 1).attr('data-target', "#" + 'newdatetimepicker')
    // get second from last of .datetimepicker
    datetimepickers.eq(datetimepickers.length - 2).attr('id', 'newdatetimepicker1')
    datetimepickers.eq(datetimepickers.length - 2).attr('data-target', "#" + 'newdatetimepicker1')
    datetimepickers.datetimepicker({
      format: "YYYY-MM-DD HH:mm",
      stepping: 15,
      sideBySide: true
    });
    $('.datetimepicker').val($(this).attr('td-date'));
    $($(this).data("bs.popover").tip).find('select').selectize();
  }).on("show.bs.popover", function () {
    $('.popover').popover('hide');
    $($(this).data("bs.popover").tip).css({ "max-width": "500px" })
  }).children().on('click', function (e) {
    e.stopPropagation();
  });
  // Activation details
  $('.activation').popover({
    html: true,
    container: 'body',
    content: function () {
      return $('#activation-details').html();
    }
  }).on("show.bs.popover", function(el) {
    $('.popover').popover('hide');
    get_activation = JSON.parse($(this).attr('activation-data'))
    get_activation_address = JSON.parse($(this).attr('activation-address'))
    start_time = new Date(get_activation['start_time']);
    end_time = new Date(get_activation['end_time']);
    $('#allocated_users_length').text($(this).attr('get_allocated_users_length'));
    $('#client_name').text($(this).attr('activation-client'));
    $('#activation_type_popover').text($(this).attr('activation-type'));
    $('#event_owner').text($(this).attr('activation-event_owner'));
    $('#location').text(get_activation['location']);
    if (get_activation_address) {
      $('#address_attributes_line_1').text(get_activation_address['line_1']);
      $('#address_attributes_line_2').text(get_activation_address['line_2']);
      $('#address_attributes_postal_code').text(get_activation_address['postal_code']);
    }
    $('#start_time').text(moment(start_time).format('HH:mm'));
    $('#end_time').text(moment(end_time).format('HH:mm'));
    $('#remarks').text(get_activation['remarks']);
    $('#edit_activation').attr("href", "conductor/activations/" + get_activation['id'] + "/edit");
    $('#edit_allocations').attr("href", "conductor/allocations/?start_date=" + moment(start_time).format('YYYY-MM-DD'));
  });
  $('body').on("shown.bs.popover", function (e) {
    $('.popover-close').click(function () { $(e.target).popover('hide') });
  });
});