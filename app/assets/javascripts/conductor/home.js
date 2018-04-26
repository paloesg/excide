$(document).ready(function () {
  $('.day').popover({
    html: true,
    title: 'New activation',
    container: 'body',
    placement: 'auto left',
    content: function () {
      return $('#popover-show').html();
    }
  }).on('shown.bs.popover', function (el) {
    $('.datetimepicker').datetimepicker({
      format: "YYYY-MM-DD HH:mm",
      stepping: 15,
      sideBySide: true
    });
    $('.datetimepicker').val($(this).attr('td-date'));
    $('.activation').unbind().click(function () {
      $.ajax({
        type: "GET",
        url: '//' + location.host + location.pathname + "/activations/" + $(this).attr('activation-id'),
        dataType: "json",
        success: function (get_activation) {
          element_target = $(el.target).data("bs.popover").tip();
          element_target.find('input, select, textarea').prop('disabled', true);
          element_target.find('.popover-title').text('Activation details');
          element_target.find('#activation_client_id').val(get_activation['activation']['client_id']);
          element_target.find('#activation_activation_type').val(get_activation['activation']['activation_type']);
          element_target.find('#activation_event_owner_id').val(get_activation['activation']['event_owner_id']);
          element_target.find('#activation_location').val(get_activation['activation']['location']);
          element_target.find('#activation_address_attributes_line_1').val(get_activation['address']['line_1']);
          element_target.find('#activation_address_attributes_line_2').val(get_activation['address']['line_2']);
          element_target.find('#activation_address_attributes_postal_code').val(get_activation['address']['postal_code']);
          element_target.find('#activation_start_time').val(get_activation['activation']['start_time']);
          element_target.find('#activation_end_time').val(get_activation['activation']['end_time']);
          element_target.find('#activation_remarks').val(get_activation['activation']['remarks']);
          element_target.find('.btn').hide();
        }
      })
    })
  }).on("show.bs.popover", function () {
    $(this).data("bs.popover").tip().css("max-width", "none");
    $('.popover').popover('hide');
  });
});