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
    // Called when there's incoming data on the websocket for this channel
    $('#comments').append(
      '<div class="comment">' + data.content + '</div>')
  }
});
