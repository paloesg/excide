// Show message validation in popover when creating activation
$(document).on("ajax:error", "form", function (xhr, status, error) {
  $(this).find('#popover_validation').text('')
  data = JSON.parse(status.responseText)
  var message, results;
  if (data) {
    results = [];
    for (var message in data) {
      results.push($(this).find('#popover_validation').prepend(' *' + message.replace(/_/g, ' ') + ' ' + data[message]));
    }
    $(this).find('.alert').show()
  }
});
$(document).ready(function () {
  // Create new activation
  $('.new_activation').popover({
    html: true,
    container: 'body',
    placement: 'auto left',
    content: function () {
      return $('#new-activation').html();
    }
  }).on('shown.bs.popover', function () {
    $('.datetimepicker').datetimepicker({
      format: "YYYY-MM-DD HH:mm",
      stepping: 15,
      sideBySide: true
    });
    $('.datetimepicker').val($(this).attr('td-date'));
  }).on("show.bs.popover", function () {
    $('.popover').popover('hide');
    $(this).data("bs.popover").tip().css({ "max-width": "500px" });
  }).children().on('click', function (e) {
    e.stopPropagation();
  });
  // Activation details
  $('.activation').popover({
    html: true,
    container: 'body',
    placement: 'auto left',
    content: function () {
      return $('#activation-details').html();
    }
  }).on("show.bs.popover", function(el) {
    $('.popover').popover('hide');
    get_activation = JSON.parse($(this).attr('activation-data'))
    get_activation_address = JSON.parse($(this).attr('activation-address'))
    start_time = new Date(get_activation['start_time']);
    end_time = new Date(get_activation['end_time']);
    $('#client_name').text($(this).attr('activation-client'));
    $('#activation_type_popover').text(get_activation['activation_type'].replace(/_/g, ' ')).css("text-transform", "capitalize");
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
  $('body').on('hidden.bs.popover', function (e) {
    $(e.target).data("bs.popover").inState.click = false;
  }).on("shown.bs.popover", function (e) {
    $('.popover-close').click(function () { $(e.target).popover('hide') });
  });
});