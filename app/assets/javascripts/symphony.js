//javascript
(function() {
  jQuery(function() {
    $('form').on('click', '.remove_fields', function(event) {
      if ($(this).closest('tr').find('.account-field').length) {
        $(".add_account").removeClass("disabled");
      }
      $(this).closest('tr').find('.destroy').val('1');
      $(this).closest('tr').hide();
      return event.preventDefault();
    });
    $('form').on('click', '.add_attribute_fields', function(event) {
      var regexp, time;
      time = new Date().getTime();
      regexp = new RegExp($(this).data('id'), 'g');
      $(".table>tbody>tr:last-child").after($(this).data('fields').replace(regexp, time));
      if ($("input[id$='" + time + "_name']").val() !== "Account") {
        $("input[id$='" + time + "_name']").removeAttr('readonly');
      } else {
        $(".add_account").addClass("disabled");
        $("select[id$='" + time + "_value']").selectize({
          dropdownParent: "body"
        });
      }
      $('.data-attributes').find('tr:last-child').find('.create').val('1');
      return event.preventDefault();
    });
    return $('input').change(function(event) {
      return $(this).closest('td').next().find('.update').val('1');
    });
  });

}).call(this);