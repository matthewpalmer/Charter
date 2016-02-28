const messageParser = require('./message-parser');
const async = require('async');

module.exports = (list, callback) => {
  const emails = splitEmails(list);
  
  async.map(emails, messageParser, (err, messages) => {
    callback(err, messages.filter(x => x.messageID)); // Filter those without IDs
  });
};

function splitEmails(list) {
  const emails = [];

  var fromField;
  var dateField;
  var nextFromField = 0;
  while (nextFromField !== -1) {
    fromField = list.indexOf('\nFrom:', nextFromField);
    dateField = list.indexOf('\nDate:', fromField);
    nextFromField = list.indexOf('\nFrom:', fromField + 1);

    const substring = list.substring(fromField, dateField);

    var emailContent = list.substring(fromField, 
      (nextFromField !== -1) ? nextFromField : list.length);
    
    if (occurrences(substring, '\n') === 1) {
      // We are going from 'From:' to 'From:', so there might be a bit of 
      // unnecessary junk at the end of the current email.
      // If the string contains a "next part" sigil, delete anything after that.
      // Otherwise, delete anything after the immediately preceding empty line.
      const nextPart = emailContent.indexOf('-------------- next part --------------');
      if (nextPart !== -1) {
        emailContent = emailContent.substring(0, nextPart);
      } else {
        // Delete anything after the last double newline (i.e. an empty line)
        const lastDoubleNewline = emailContent.lastIndexOf('\n\n');

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

