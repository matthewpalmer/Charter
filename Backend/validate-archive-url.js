const messageNumberFromArchiveURL = require('./message-number-from-archive-url');
const async = require('async');
const sprintf = require('sprintf-js').sprintf;
const logger = require('./logger/logger');
const idMatchesActualArchiveURL = require('./id-matches-archive-url');

/**
 * This is a side-effect heavy module. Check that the most recent document's archive URL
 * points to the right page. If it does, do nothing. If it does not, update the message
 * referenced by the page and then update the archive URL for all documents chronologically
 * after that document.
 * @param  {Object} collection Databse collection
 * @return {undefined}            
 */
module.exports = function(collection) {
  logger('validate-archive-url: Beginning validation');

  collection.find({}, { _id: 1, archiveURL: 1 }).sort({ date: -1 }).limit(1).toArray(function(err, docs) {
    logger('validate-archive-url: Found docs', docs);

    if (err || !docs || !docs[0]) {
      logger('validate-archive-url: No document retrieved.');
      return;
    }

    var id = docs[0]._id;
    var archiveURL = docs[0].archiveURL;

    idMatchesActualArchiveURL(id, archiveURL, function(success, actualMessageId) {
      logger(success, actualMessageId);
      if (!success && actualMessageId) {
        // The page was retrieved but did not match. Find the referenced message and set its archive URL. Then recompute
        // all following archive URLs.
        logger('validate-archive-url: Page retrieved, did not match');
        
        collection.update({_id: actualMessageId}, { $set: { archiveURL: archiveURL }}, function(err, results) {
          recomputeArchiveURLsAfterMessageWithId(collection, actualMessageId);
        });
      } else if (success && actualMessageId) {
        // The page was retrieved and matched. Do nothing.
        logger('validate-archive-url: Page retrieved, matched');
      } else {
        // The page was not retrieved
        logger('validate-archive-url: Page not retrieved.');
      }
    });
  });
};

var recomputeArchiveURLsAfterMessageWithId = function(collection, messageID) {
  logger('validate-archive-url: Recompute archive URLs after', messageID);

  var queue = async.queue(function(doc, callback) {
    collection.update({
      _id: doc._id
    }, {
      $set: { archiveURL: doc.archiveURL }
    }, {
      w: 1
    }, callback);
  }, Infinity);

  // This could be bad because we'll need to iterate from the start of the collection every time...
  var cursor = collection.find({}).sort({ date: 1 });

  // Documents will be updated from oldest -> newest. The previous item's
  // message number must be correct.
  var messageNumber;

  // We don't want to update any records that come before the `messageID` chronologically.
  // Does mongo have a built in way of doing this?
  var hasFoundRoot = false;

  queue.drain = function() {
    if (cursor.isClosed()) {
      logger('validate-archive-url: All items processed');
    }
  };

  // No actual value, just putting this here for logging.
  var countOfPassedDocuments = 0;

  function processItem(err, item) {
    if (item === null) {
      logger('validate-archive-url: Recompute is returning');
      cursor.close();
      queue.drain();
      return;
    }

    // Skip until we get to `messageID`
    if (!hasFoundRoot && item._id != messageID) {
      countOfPassedDocuments++;
      cursor.nextObject(processItem);
      return;
    }

    // We're at `messageID`.
    if (!hasFoundRoot && item._id == messageID) {
      logger('validate-archive-url: passed', countOfPassedDocuments, 'documents before root');
      hasFoundRoot = true;
    }

    if (!messageNumber) {
      // At the beginning. We know that the current item has the right archive URL (i.e. message number) 
      // since we just set it.
      messageNumber = messageNumberFromArchiveURL(item.archiveURL);
    } else {
      messageNumber++;
    }

    var fMessageNumber = sprintf('%06d.html', messageNumber);
    var newArchiveURL = item.archiveURL.replace(/\d+\.html$/, fMessageNumber);
    logger('validate-archive-url: Recompute - replace', item.archiveURL, newArchiveURL);
    item.archiveURL = newArchiveURL;
    queue.push(item);

    cursor.nextObject(processItem);
  }

  cursor.nextObject(processItem);
};
