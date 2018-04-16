function allDay(element) {
  $(element).closest('td').find("input").not(element).prop("checked", element.checked)
}

function day(element) {
  $(element).closest('td').find("#all_day").prop("checked", false)
  all_input = $(element).closest('td').find("input:checkbox").slice(1)
  all_checked = $(element).closest('td').find("input:checkbox:checked")
  if (all_checked.length == all_input.length) {
    $(element).closest('td').find("#all_day").prop("checked", true)
  }
}