var MongoClient = require('mongodb').MongoClient;
var assert = require('assert');
var async = require('async');
var convertDateToISOString = require('./date-to-iso-string');
var fixInReplyTo = require('./fix-in-reply-to');
var url = 'mongodb://localhost:27017/charter';
var logger = require('./logger/logger');

// This module reformats and fixes up some of the database contents after an import.
// It should only be run manually after an import.

MongoClient.connect(url, function(err, db) {
  logger("Connected correctly to server.");

  async.series([
    (callback) => {
      logger('Formatting dates... ');
      formatDate(db, callback);
    },
    (callback) => {
      logger('Fixing threading...');
      fixThreading(db, callback);
    },
    (callback) => {
      logger('Adding descendants...');
      addDescendants(db, callback);
    }
  ], () => {
    logger('Finished formatting the database.');
    db.close();
  });
});

var updateSet = function(collection, itemsToUpdateQuery, eachItem, updateSetCallback) {
  var queue = async.queue(eachItem, Infinity);

  queue.drain = function() {
    if (cursor.isClosed()) {
      logger('All items processed');
      updateSetCallback();
    }
  };

  var hasMatchesCursor = collection.find(itemsToUpdateQuery).limit(1);
  var cursor = collection.find(itemsToUpdateQuery);

  hasMatchesCursor.nextObject(function(err, object) {
    if (object !== null) {
      cursor.each(function(err, doc) {
        if (err) throw err;
        if (doc) queue.push(doc);
      });
    } else {
      cursor.close();
      queue.drain();
    }
  });
};

var addDescendants = function(db, callback) {
  var match = {};
  var collection = db.collection('emails');

  updateSet(collection, match, function(email, callback) {
    collection.updateMany(
      { _id: { $in: email.references }},
      { $addToSet: { descendants: email._id }},
      { w: 1 },
      callback);
  }, callback);
};

var fixThreading = function(db, callback) {
  var match = { inReplyTo: null };
  var collection = db.collection('emails');

  updateSet(collection, match, function(email, callback) {
    fixInReplyTo(collection, email, function(fixedEmail) {
      logger('fixed email is', fixedEmail);

      collection.update({
        _id: fixedEmail._id
      }, {
        $set: { inReplyTo: fixedEmail.inReplyTo }
      }, {
        w: 1
      }, callback);
    });
  }, callback);
};

var formatDate = function(db, callback) {
  var match = { date: { $type: 2 }};
  var collection = db.collection('emails');
  updateSet(collection, match, function(email, callback) {
    var newDate = new Date(convertDateToISOString(email.date));
    collection.update({
      _id: email._id
    }, {
      $set: { date: newDate }
    }, {
      w: 1
    }, callback);
  }, callback);
};
