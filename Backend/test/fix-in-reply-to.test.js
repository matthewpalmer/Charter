const expect = require('expect.js');
const fixInReplyTo = require('../fix-in-reply-to');

// Root (the inReplyTo should not make a difference)
const emailOne = {
  inReplyTo: 'm2bn7p3d7b.fsf@apple.com',
  _id: 'E375C44E-8D6E-4DED-B237-0350CF315F24@akkyra.com',
  subject: '[swift-evolution] [Guidelines, First Argument Labels]: Prepositions inside the parens',
  references: ['m2bn7p3d7b.fsf@apple.com']
};

// Dave Abrahams doesn't have the inReplyTo
const emailTwo = {
  references: [ 'm2bn7p3d7b.fsf@apple.com', 'E375C44E-8D6E-4DED-B237-0350CF315F24@akkyra.com' ],
  _id: 'm2fuwzyt71.fsf@eno.apple.com',
  subject: 'Re: re:[swift-evolution] [Guidelines, First Argument Labels]: Prepositions inside the parens'
};

// Cross-thread reference
const emailThree = {
  references: [ 'E375C44E-8D6E-4DED-B237-0350CF315F24@akkyra.com' ],
  _id: '12345@blah.apple.com',
  subject: 'Some other thread'
};

describe('fix-in-reply-to', () => {
  it('should set the inReplyTo for an email that is missing one to the last entry in references', () => {
    const collection = {};
    collection.findOne = (o, cb) => {
      expect(o._id).to.equal(emailOne._id);
      cb(null, emailOne);
    };

    fixInReplyTo(collection, emailOne, (fixed) => {
      expect(emailOne).to.equal(fixed);
    });

    fixInReplyTo(collection, emailTwo, function(fixed) {
      expect(fixed.inReplyTo).to.equal(emailOne._id);
    });

    fixInReplyTo(collection, emailThree, function(fixed) {
      expect(fixed).to.equal(emailThree);
    });
  });

  it('should correctly handle null values and ensure leading `Re:` text is stripped', () => {
    const emailFour = {
      "_id" : "m2wpq22587.fsf@eno.apple.com",
      "from" : "dabrahams at apple.com (Dave Abrahams)",
      "subject" : "Re: [swift-evolution] Add clamp(value: Bound) -> Bound to ClosedInterval",
      "references" : [ "1455753068.1544585.524365562.4E6AF36C@webmail.messagingengine.com" ],
      "mailingList" : "swift-evolution",
      "archiveURL" : "https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160215/010554.html",
      "descendants" : [ "m2wpq22587.fsf@eno.apple.com" ],
      "inReplyTo" : null
    };

    const emailFive = {
      "_id" : "1455753068.1544585.524365562.4E6AF36C@webmail.messagingengine.com",
      "from" : "kevin at sb.org (Kevin Ballard)",
      "subject" :"[swift-evolution] Add clamp(value: Bound) -> Bound to ClosedInterval",
      "references" : null,
      "mailingList" : "swift-evolution",
      "archiveURL" : "https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160215/010549.html",
      "inReplyTo" : null,
      "descendants" : [ "m2wpq22587.fsf@eno.apple.com" ]
    };

    const collection = {};

    collection.findOne = function(o, cb) {
      expect(o._id).to.equal(emailFive._id);
      cb(null, emailFive);
    };

    fixInReplyTo(collection, emailFour, function(fixed) {
      expect(fixed.inReplyTo).to.equal(emailFive._id);
    });
  });
});
