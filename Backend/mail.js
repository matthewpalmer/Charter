var mailin = require('mailin');
var convertDateToISOString = require('./date-to-iso-string');
var MongoClient = require('mongodb').MongoClient;
var assert = require('assert');
var listPeriod = require('./list-period');
var messageNumberFromArchiveURL = require('./message-number-from-archive-url');
var sprintf = require('sprintf-js').sprintf;
var validateArchiveURLs = require('./validate-archive-url');
var fixInReplyTo = require('./fix-in-reply-to');
var logger = require('./logger/logger');

var url = 'mongodb://localhost:27017/charter';

MongoClient.connect(url, function(err, db) {
  assert.equal(null, err);
  logger("Mail: connected to database.");
  var collection = db.collection('emails');

  // setInterval(function() {
  //   validateArchiveURLs(collection);
  // }, 1000 * 60 * 15); // Every 15 mins

  mailin.start({
    port: 25,
    disableWebhook: true // Disable the webhook posting.
  });

  /* Event emitted when a connection with the Mailin smtp server is initiated. */
  mailin.on('startMessage', function (connection) {
    logger(connection);
  });

  mailin.on('message', function(connection, data, html) {
    fixInReplyTo(collection, parseMessage(data, html), function(email) {
      collection.find({mailingList: email.mailingList}, {archiveURL: 1}, {limit: 1}).sort({date: -1}).toArray(function(err, docs) {
        if (err) return;

        // Compute period and message number from parsed message and previous message URL
        var period = listPeriod(email.mailingList, email.date);

        var newArchiveURL;

        if (docs && docs[0]) {
          logger('Previous docs found.');
          if (!docs[0].archiveURL) {
            logger('Doc did not have archive URL');
            newArchiveURL = '';
          } else {
            logger('Doc had archive URL');
            var previousMessageNumber = messageNumberFromArchiveURL(docs[0].archiveURL);
            var messageNumber = previousMessageNumber + 1;
            var fMessageNumber = sprintf('%06d', messageNumber);
            //https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160208/009359.html
            newArchiveURL = 'https://lists.swift.org/pipermail/' + email.mailingList + '/' + period + '/' + fMessageNumber + '.html';
          }

          email.archiveURL = newArchiveURL;
        } else {
          logger('No previous docs found.');
        }

        // Each email counts itself as a descendant
        email.descendants = [email._id];

        logger('Saving parsed message', email);

        collection.save(email, { w: 1 }, function(err, result) {
          logger('Saved.');

          // Now update the descendants for each email this email references
          logger('Updating parent descendants');
          collection.updateMany(
            { _id: { $in: email.references }},
            { $addToSet: { descendants: email._id }},
            { w: 1 }, function() {
              logger('Updated.');
            });
        });
      });
    });
  });
});

var parseMessage = function(data, html) {
  if (!data || !(data.headers) || !(data.text)) {
    throw new Error('Could not retrieve required information from email');
  }

  var id = data.messageId;
  
  // Format: brent at architechies.com (Brent Royal-Gordon)
  // Hmmm... it's possible for people to not set a name when they sign up for the list... 
  // is that relevant?
  var fromEmailComponents = data.replyTo[0].address.split('@');
  var from = fromEmailComponents[0] + ' at ' + fromEmailComponents[1] +
             ' (' + (data.replyTo[0].name || '') + ')';


  var dateString = data.headers.date;
  var subject = data.headers.subject;

  var inReplyTo = data.inReplyTo;
  var references = data.references; // Make sure it's an array
  var mailingList = data.from[0].address.split('@')[0];

  var content = data.text;

  var obj = {
    _id: id,
    from: from,
    date: new Date(convertDateToISOString(dateString)),
    subject: subject,
    references: references,
    mailingList: mailingList,
    content: content
  };

  if (inReplyTo && inReplyTo.length > 0) {
    obj.inReplyTo = inReplyTo[0];
  }

  return obj;
};

module.exports.parseMessage = parseMessage;
