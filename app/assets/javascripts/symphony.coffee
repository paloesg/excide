# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('form').on 'click', '.remove_fields', (event) ->
    console.log($(this).prev())
    $(this).next('input[type=hidden]').val('1')
    $(this).closest('tr').hide()
    event.preventDefault()

  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(".table>tbody>tr:last-child").after($(this).data('fields').replace(regexp, time))
    event.preventDefault()