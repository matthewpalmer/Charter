var logger = require('./logger/logger');

// Fix the In-Reply-To for an email (cough Dave Abrahams cough) by inspecting
// the references header field.
// Note that this does *not* save the new email to the database.
module.exports = function(collection, email, callback) {
  logger('fix-in-reply-to: Starting to fix email');
  if (email.inReplyTo) {
    logger('fix-in-reply-to: inReplyTo already set');
    // No-op if we already have an in-reply-to field set
    return callback(email);
  }

  if (!email.references || email.references.length === 0) {
    logger('fix-in-reply-to: no references');
    return callback(email);
  }

  // The last email ID in `references` is our best bet for fixing the in-reply-to for this email.
  // (Note that most of the time in-reply-to is just the same as the last of the references, even
  // when fixing is not necessary.)
  // We'll also check that the subjects match just to be sure.
  var lastReferenceId = email.references[email.references.length - 1];

  collection.findOne({ _id: lastReferenceId }, function(err, doc) {
    if (err || !doc) {
      logger('fix-in-reply-to: error finding ');
      return callback(email);
    }

    // Check if subjects match after removing any meaningless additions
    // (this match is a bit fuzzy--it's not too bad if we over-match some stuff here.)
    var originalSubject = email.subject;
    var parentSubject = doc.subject;
    var replyRegex = /re:/gi;
    var whiteSpaceRegex = /\s/gi;
    
    originalSubject = originalSubject.replace(replyRegex, '').replace(whiteSpaceRegex, '');
    parentSubject = originalSubject.replace(replyRegex, '').replace(whiteSpaceRegex, '');

    if (originalSubject.toLowerCase() === parentSubject.toLowerCase()) {
      logger('fix-in-reply-to: update inReplyTo');
      email.inReplyTo = doc._id;
    } else {
      logger('fix-in-reply-to: subjects did not match', originalSubject, parentSubject);
    }

    return callback(email);
  });
};
