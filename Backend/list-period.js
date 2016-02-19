var moment = require('moment');

/**
 * Converts a date to its most recent Monday and presents 
 * in the format `Week-of-Mon-20160208/009359`. Eventually, this method
 * will work for days/periods other than each Monday (which is why listId is required).
 * 
 * @param  {String} listId swift-evolution, swift-users, swift-dev
 * @param  {Date} date     The date object to determine the period for
 * @return {String}        String of the format given above.
 */
module.exports = function(listId, date) {
  if (!(listId === 'swift-evolution' || listId === 'swift-dev' || listId === 'swift-users')) {
    throw new Error('list-period takes a valid list id as the first argument');
  }

  var day = new Date(date.toISOString());
  day.setDate(day.getDate() - (day.getDay() + 6) % 7); // Go to Monday

  var mo = moment(day);
  return 'Week-of-Mon-' + mo.format('YYYYMMDD');
};
