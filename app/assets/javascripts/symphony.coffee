# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('form').on 'click', '.remove_fields', (event) ->
    if $(this).closest('tr').find('.account-field').length
      $(".add_account").removeClass("disabled")
    $(this).closest('tr').find('.destroy').val('1')
    $(this).closest('tr').hide()
    event.preventDefault()

  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(".table>tbody>tr:last-child").after($(this).data('fields').replace(regexp, time))
    if $("input[id$='"+time+"_name']").val() != "Account"
      $("input[id$='"+time+"_name']").removeAttr('readonly')
    else
      $(".add_account").addClass("disabled")
    $(this).prev().find('tr:last-child').find('.create').val('1')
    event.preventDefault()

  $('input').change (event) ->
    $(this).closest('td').next().find('.update').val('1')