const expect = require('expect.js');
const listPeriod = require('../list-period');
const moment = require('moment');

describe('list-period', () => {
  it('should convert a date for swift-evolution into the correct list period format in the right timezone', () => {
    // Construct our date
    const dateString = 'Sun, 07 Feb 2016 22:14:32 -0800';
    const format = 'ddd, D MMM YYYY HH:mm:ss ZZ';
    const date = moment(dateString, format);

    expect(listPeriod('swift-evolution', date)).to.equal('Week-of-Mon-20160208');
  });

  it('should throw an error for unsupported lists', () => {
    expect(listPeriod).withArgs('swift-build', new Date()).to.throwError();
  })
});


