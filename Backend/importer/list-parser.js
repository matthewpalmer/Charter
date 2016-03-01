const messageParser = require('./message-parser');
const async = require('async');

module.exports = (list, callback) => {
  const emails = splitEmails(list);
  
  async.map(emails, messageParser, (err, messages) => {
    callback(err, messages.filter(x => x.messageID));
  });
};

function splitEmails(list) {
  const emails = [];

  var fromField;
  var dateField;
  var nextFromField = 0;
  var nextPart;
  var emailContent;
  var substring;
  var lastDoubleNewline;
  var isLastEmail = false;

  while (nextFromField !== -1) {
    fromField = list.indexOf('\nFrom:', nextFromField);
    dateField = list.indexOf('\nDate:', fromField);
    nextFromField = list.indexOf('\nFrom:', fromField + 1);

    substring = list.substring(fromField, dateField);

    // Make sure the 'From:' was followed by a 'Date:', which increases the 
    // likelihood (but does not guarantee) that this is actually the header.
    if (occurrences(substring, '\n') === 1) {
      if (nextFromField === -1) {
        isLastEmail = true;
      } else {
        isLastEmail = false;
      }

      emailContent = list.substring(fromField,  isLastEmail ? list.length : nextFromField);

      // We are going from 'From:' to 'From:', so there might be a bit of 
      // unnecessary junk at the end of the current email.
      // If the string contains a "next part" sigil, delete anything after that.
      // Otherwise, delete anything after the immediately preceding empty line.

      nextPart = emailContent.indexOf('-------------- next part --------------');
      if (nextPart !== -1) {
        emailContent = emailContent.substring(0, nextPart);
      } else if (!isLastEmail) {
        // Delete anything after the last double newline (i.e. an empty line)
        // (unless this is the last message in the list)
        lastDoubleNewline = emailContent.lastIndexOf('\n\n');

        emailContent = emailContent.substring(0, lastDoubleNewline);
      }

      emails.push(emailContent.trim('\n'));
    }
  }

  return emails;
}

// Source: http://stackoverflow.com/a/7924240/1695900
function occurrences(string, subString, allowOverlapping) {

    string += "";
    subString += "";
    if (subString.length <= 0) return (string.length + 1);

    var n = 0,
        pos = 0,
        step = allowOverlapping ? 1 : subString.length;

    while (true) {
        pos = string.indexOf(subString, pos);
        if (pos >= 0) {
            ++n;
            pos += step;
        } else break;
    }
    return n;
}

