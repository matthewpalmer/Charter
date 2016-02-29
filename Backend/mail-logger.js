var mailin = require('mailin');

mailin.start({
  port: 25,
  disableWebhook: true // Disable the webhook posting.
});

/* Event emitted when a connection with the Mailin smtp server is initiated. */
mailin.on('startMessage', function (connection) {
  console.log(connection);
});

mailin.on('message', function(connection, data, html) {
  console.log(data, html);
});
