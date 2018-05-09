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
    title: 'New activation',
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
    title: 'Activation details',
    container: 'body',
    placement: 'auto left',
    content: function () {
      return $('#activation-details').html();
    }
  }).on("shown.bs.popover", function (el) {
    element_target = $(el.target).data("bs.popover").tip();
    get_activation = JSON.parse($(this).attr('activation-data'))
    get_activation_address = JSON.parse($(this).attr('activation-address'))
    start_time = new Date(get_activation['start_time']);
    end_time = new Date(get_activation['end_time']);
    element_target.find('#client_name').text($(this).attr('activation-client'));
    element_target.find('#activation_type').text(get_activation['activation_type'].replace(/_/g, ' '));
    element_target.find('#event_owner').text($(this).attr('activation-event_owner'));
    element_target.find('#location').text(get_activation['location']);
    if (get_activation_address) {
      element_target.find('#address_attributes_line_1').text(get_activation_address['line_1']);
      element_target.find('#address_attributes_line_2').text(get_activation_address['line_2']);
      element_target.find('#address_attributes_postal_code').text(get_activation_address['postal_code']);
    }
    element_target.find('#start_time').text(moment(start_time).format('HH:mm'));
    element_target.find('#end_time').text(moment(end_time).format('HH:mm'));
    element_target.find('#remarks').text(get_activation['remarks']);
    element_target.find('#edit_link').attr("href", "conductor/activations/" + get_activation['id'] + "/edit");
  }).on("show.bs.popover", function() {
    $('.popover').popover('hide');
  });
  $('body').on('hidden.bs.popover', function (e) {
    $(e.target).data("bs.popover").inState.click = false;
  });
});