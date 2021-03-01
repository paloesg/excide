import Tagify from '@yaireo/tagify';
$(document).on("turbolinks:load", function () {
  // The DOM element you wish to replace with Tagify
  let clients = document.getElementById('clients_tags');
  let service_lines = document.getElementById('service_lines_tags');
  let projects = document.getElementById('projects_tags');
  let tasks = document.getElementById('tasks_tags');

  // initialize Tagify on the above input node reference
  new Tagify(clients, {
    callbacks: {
      "edit:updated": (e) => updateTags(e.detail.data),
      "add": (e) => createTags(e.detail.data, e.detail.tagify.DOM.originalInput.id)
    }
  });
  new Tagify(service_lines, {
    callbacks: {
      "edit:updated": (e) => updateTags(e.detail.data),
      "add": (e) => createTags(e.detail.data, e.detail.tagify.DOM.originalInput.id)
    }
  });
  new Tagify(projects, {
    callbacks: {
      "edit:updated": (e) => updateTags(e.detail.data),
      "add": (e) => createTags(e.detail.data, e.detail.tagify.DOM.originalInput.id)
    }
  });
  new Tagify(tasks, {
    callbacks: {
      "edit:updated": (e) => updateTags(e.detail.data),
      "add": (e) => createTags(e.detail.data, e.detail.tagify.DOM.originalInput.id)
    }
  });

  async function createTags(data, c_type){
    let value = data.value;
    let type = c_type.slice(0, -6);
    $.ajax({
      type: "PATCH",
      url: "conductor/events/create_tags",
      data: {value: value, type: type},
      dataType: "JSON"
    }).done(function(data){
      // If success request, it will change the color of the tag to green color for a short while before changing back to normal color
      $("tag[value='" + value + "']").css("cssText", "background: #BBEEBB !important");
      setTimeout(function(){
      $("tag[value='" + value + "']").css("cssText", "");
      }, 3000);
    }).fail(function(data) {
      // If fail, it will be red
      $("tag[value='" + value + "']").css("cssText", "background: #FCE5E5 !important");
      setTimeout(function(){
      $("tag[value='" + value + "']").css("cssText", "");
      }, 3000);
    });
  }

  async function updateTags(data){
    let id = data.id
    $.ajax({
      type: "PATCH",
      url: "conductor/events/update_tags",
      data: {value: data.value, id: id},
      dataType: "JSON"
    }).done(function(data){
      // If success request, it will change the color of the tag to green color for a short while before changing back to normal color
      $("#" + id).css("cssText", "background: #BBEEBB !important");
      setTimeout(function(){
        $("#" + id).css("cssText", "");
      }, 3000);
    }).fail(function(data) {
      // If fail, it will be red
      $("#" + id).css("cssText", "background: #FCE5E5 !important");
      setTimeout(function(){
        $("#" + id).css("cssText", "");
      }, 3000);
    });
  }
});
