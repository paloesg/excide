import Tagify from '@yaireo/tagify';
$(document).on("turbolinks:load", function () {
  // The DOM element you wish to replace with Tagify
  var clients = document.getElementById('clients_tags');
  var service_lines = document.getElementById('service_lines_tags');
  var projects = document.getElementById('projects_tags');
  var tasks = document.getElementById('tasks_tags');

  // initialize Tagify on the above input node reference
  new Tagify(clients);
  new Tagify(service_lines);
  new Tagify(projects);
  new Tagify(tasks);
});
