import consumer from "./consumer"

consumer.subscriptions.create("NoteChannel", {
  connected() {
    console.log("Connected to note channel!")
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log("What is data received: ", data)
    // If empty state is present, remove it before appending the comments
    if ($(".empty-note").length) {
      $(".empty-note").empty();
    }
    // Called when there's incoming data on the websocket for this channel
    $('#comments').append('<div class="row m-2 p-5"><div class="col-md-1"><img class="comment-user-icon mb-3" src="/packs/media/src/images/symphony/user-avatar-placeholder-5271067041bbca781be356699c1a348a.jpg"></div><div class="col-md-11"><div class="row"><span class="h2 font-weight-boldest mr-4">' + data.user_name + '</span><span class="text-muted mt-2">' + data.created_at +'</span></div><div class="row mt-5"><p class="comment-font-size">' + data.content + '</p></div></div></div>')
  }
});
