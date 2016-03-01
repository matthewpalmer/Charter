const MailParser = require("mailparser").MailParser;

module.exports = (message, callback) => {
  const mailparser = new MailParser({defaultCharset: 'utf8'});
  mailparser.on('end', (mail) => {
    const output = {};
    output.subject = mail.subject;
    output.references = mail.references;

    if (mail.inReplyTo) {
      // We make the assumption throughout the app that 
      // there will only be one 'inReplyTo'
      output.inReplyTo = mail.inReplyTo[0];  
    }
    
    output.from = mail.headers.from;
    output.content = mail.text;
    output.date = mail.headers.date;

    if (output.date === 'Tue, 23 Feb 2016 12:09:25 -0800') {
      // console.log('\n\n\n');
      // console.log(output);
      // console.log('\n\n\n');
      // console.log(mail);
      // console.log('\n\n\n');
    }

    output.messageID = mail.messageId;
    return callback(null, output);
  });

  // Messages often have some unnecessary (or invalid) prelude
  // that we need to strip. Delete anything before the first header
  // field, 'From'
  // (Note that this is an assumption that's not necessarily spec-compliant).
  const beginning = message.indexOf('\nFrom:');
  message = message.substring(beginning + 1, message.length);

  if (message.indexOf('Date: Tue, 23 Feb 2016 12:09:25 -0800') !== -1) {
    // console.log('***\n***\n\n', message, '\n***\n');
  }

  mailparser.write(message);
  mailparser.end();
};