const expect = require('expect.js');
const listParser = require('./list-parser');
const fs = require('fs');
const path = require('path');

const getTestFile = (name, callback) => {
  fs.readFile(path.join(__dirname, 'sample', name), 'utf8', callback);
};

/*

Note that some of these files are not formatted correctly within each message.
Namely, they are missing indentation for stuff like `references` and multi-line
`subject`s. I've deliberately tried to avoid asserting too much about the actual
content of each message (since that is the domain of the message-parser module).
This might come back to bite us.

 */


describe('list-parser', () => {
  it('List-1: should parse a mailing list archive text file to an array of emails', (done) => {
    getTestFile('List-1', (_, list) => {
      listParser(list, (_, messages) => {
        expect(messages.length).to.be(3);

        expect(messages[0].from).to.be('dturnbull at gmail.com (David Turnbull)');
        expect(messages[0].messageID).to.be('CANEjtCDg5mCCwB5xqvshGeLvx4wdNyZtLwN+7GLNwAqKYNhE8g@mail.gmail.com');

        const expectedContent = `On Sun, Jan 24, 2016 at 9:55 PM, Chris Lattner <clattner at apple.com> wrote:\n\n> Are you willing/able to share the code for your project?  That definitely\n> sounds strange,\n>\n\nSoitenly: https://github.com/AE9RB/SwiftGL\n\nThe 28,000 lines of loader code are fine. The 6,000 lines of math libraries\nare the problem.\n\nI'm sure it's something to do with prototypes and generics. You can change\nin Types.swift:\npublic protocol FloatingPointScalarType : ScalarType\nto:\npublic protocol FloatingPointScalarType : ScalarType, FloatingPointType\nand make the problem a bit worse. This is something I'd actually like to\nuse, except I don't because a few "where constraints" do what I need\nwithout the build slowdown.\n\nSwift 2.1 or 2.2-dev doesn't make a difference. The C++ compiler I bench\nagainst is also llvm. The compiled binaries are truly fast (with WMO). It's\nonly the development process that's too slow because of build times.\n\n-David "nyuk nyuk nyuk" Turnbull`;
        expect(messages[0].content).to.be(expectedContent);

        const expectedContent2 = `In the language guide on the apple website, https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html#//apple_ref/doc/uid/TP40014097-CH42-ID542\n\nIt says the following assignments to x and y are equivalent:\nfunc someThrowingFunction() throws -> Int { ... }\nlet x = try? someThrowingFunction()\n// x has type \`Int?\`\n\nlet y: Int?\ndo {\ny = try someThrowingFunction()\n} catch {\ny = nil\n}\n\nHowever this isn’t the case if someThrowingFunction also returns an optional, say:\n\nfunc someThrowingFunction() throws -> Int? { ... }\n\nThe type of x would be \`Int??\`, but the type of y is still \`Int?\`, is there some way to make the \`try?\` return an \`Int?\` instead of a double optional, which is not very helpful.\n\nThanks,\nJonathan`;
        expect(messages[2].content).to.be(expectedContent2);
        done();
      });
    });
  });

  it('List-2: should parse a mailing list archive text file to an array of emails', (done) => {
    getTestFile('List-2', (_, list) => {
      listParser(list, (_, messages) => {
        // N.B. There's a sneaky one in this set where a message quotes another message and includes its
        // 'From:' and 'Message-ID:'--so if you Command-F for Message-ID you'll get misled.
        // See message 5664713E.1050702@brockerhoff.net
        expect(messages.length).to.be(338);
        done();
      });
    });
  });

  it('List-3: should parse a mailing list archive text file to an array of emails', (done) => {
    getTestFile('List-3', (_, list) => {
      listParser(list, (_, messages) => {
        expect(messages.length).to.be(1444); // Maybe this should be 1445...
        done();
      });
    });
  });
});
