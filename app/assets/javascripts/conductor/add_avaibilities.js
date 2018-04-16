function allDay(element) {
  $(element).parent().parent().find("input").not(element).prop("checked", element.checked)
}

function day(element) {
  $(element).parent().parent().find("input")[1].checked = false
  all_input = $(element).parent().parent().find("input:checkbox").slice(1)
  all_checked = $(element).parent().parent().find("input:checkbox:checked")
  if (all_checked.length == all_input.length) {
    $(element).parent().parent().find("input")[1].checked = true
  }
}