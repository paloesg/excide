import consumer from "./consumer"

$(document).on('turbolinks:load', function () {
  consumer.subscriptions.create({
    channel: "NoteChannel",
    outlet_id: $('.message-wrapper').attr('data-outlet-id')
  }, {
    connected() {
      console.log("Connected to note channel!")
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      // If empty state is present, remove it before appending the comments
      if ($('.empty-note').length) {
        $('.empty-note').empty();
      }
      // Construct the elements to be appended
      let elements = '<div class="row m-2 p-5"><div class="col-md-1"><img class="comment-user-icon mb-3" src="/packs/media/src/images/motif/avatar-no-photo-1880232c51f988fbc4fefc65032de78f.svg"></div><div class="col-md-11"><div class="row"><span class="h2 font-weight-boldest mr-4">' + data.user_name + '</span><span class="text-muted mt-2">' + data.created_at +'</span></div>';

      elements += '<div class="row mt-5"><p class="comment-font-size">' + data.content + '</p></div>';
      // If comments comes from workflow, show a link to the workflow page, displaying <TEMPLATE_TITLE> - <TASK_INSTRUCTION>
      if (data.wf_id) {
        elements += '<div class="row mt-5"><div class="badge badge-motif p-2"><span class="mr-3"><i class="material-icons-outlined align-middle">assignment</i></span><a target="_blank" class="text-primary tag-font-size" href="/motif/outlets/' + data.outlet_id + '/workflows/' + data.wf_id + '">' + data.tem_title + ' - ' + data.task + '</a></div></div></div>';
      }

      // Called when there's incoming data on the websocket for this channel. Append HTML elements constructed above to #comments
      $('#comments').append(elements);

      // Remove the text field value by resetting the form
      $('form#new_note')[0].reset();
      // Disable the submit button again
      $('.sendButton').prop('disabled',true);
    }
  })
})
