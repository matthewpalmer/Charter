// https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160208/009359.html

module.exports = function(archiveURL) {
  var components = archiveURL.split('/');
  var lastComponent = components[components.length - 1];
  var number = lastComponent.split('.html')[0];
  return Number(number);
};