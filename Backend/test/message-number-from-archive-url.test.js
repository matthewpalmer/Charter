const expect = require('expect.js');
const messageNumberFromArchiveURL = require('../message-number-from-archive-url');

describe('message-number-from-archive-url', () => {
  it('should extract the correct message number from a given archive URL', () => {
    const url = 'https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160208/009359.html';
    expect(messageNumberFromArchiveURL(url)).to.equal(9359);
  })
})
