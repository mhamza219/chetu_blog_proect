import consumer from "channels/consumer"

// consumer.subscriptions.create("NotificationChannel", {
//   connected() {
//     console.log("connected to notificaiton channel");
//     // Called when the subscription is ready for use on the server
//   },

//   disconnected() {
//     // Called when the subscription has been terminated by the server
//   },

//   received(data) {
//     alert("New Notification" + data.content);
//     // Called when there's incoming data on the websocket for this channel
//   }
// });
