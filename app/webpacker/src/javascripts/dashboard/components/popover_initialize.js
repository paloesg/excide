// THIS IS DEPRECATED OH NO.
$(document).on("turbolinks:load", function() {
  $('[data-toggle="task_popover"]').popover({
    html: true,
    container: 'body',
    trigger: 'focus',
    content: function () {
      return $('#task-popover-content').html();
    }
  }).on("show.bs.popover", function () {
    task_details = JSON.parse($(this).attr('task-details'))
    $('#next_reminder').text(task_details['next_reminder'])
    $('#completed_by').text(task_details['completed_by'])
    $('#completed_on').text(task_details['completed_on'])
    $('#stop_reminder').attr("href", window.location+"/stop_reminder/" + task_details['task_id'] + "?action_id=" + task_details['action_id']);
    if (task_details['set_reminder'] && task_details['next_reminder'] != '') {
      $('#stop_reminder').show()
    } else {
      $('#stop_reminder').hide()
    }
  })
});