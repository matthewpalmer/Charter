module.exports = function(message) {
  if (process.env.NODE_ENV !== 'test') {
    console.log(message);
  }
};