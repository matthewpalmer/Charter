var moment = require('moment');

module.exports = function(dateString) {
  var format = 'ddd, D MMM YYYY HH:mm:ss ZZ';
  var date = moment(dateString, format);
  return date.toISOString();
};
