const logger = require('./logger/logger');
const request = require('request');
const cheerio = require('cheerio');
const url = require('url');

// Callback takes a bool and actual message id as arguments, bool is true if they match, actual message id is null if not found.
module.exports= function(id, archiveURL, callback) {
  if (!id || !archiveURL) {
    return callback(false);
  }

  request(archiveURL, function(err, res, html) {
    if (err) {
      logger(err, res, html);
      logger('Error requesting', archiveURL);
      return callback(false, null);
    }

    var $ = cheerio.load(html);

    var el = $('body a');

    // <a href="mailto:swift-evolution%40swift.org?Subject=Re:%20Re%3A%20%5Bswift-evolution%5D%20Brainstorming%3A%20Optional%20sugar%20inferred%20map&amp;In-Reply-To=%3CF5A3A36C-7EF5-440C-902E-81BF7F664801%40gmail.com%3E" title="[swift-evolution] Brainstorming: Optional sugar inferred map">possen at gmail.com
           // </a>
    var href = el.attr('href');

    if (!href) {
      return callback(false, null);
    }

    var parsedURL = url.parse(href, true);
    var messageID = parsedURL.query['In-Reply-To'];

    if (!messageID) {
      logger('Invalid web page for', archiveURL);
      return callback(false, null);
    }

    var formattedMessageID = messageID.replace(/[<>]/g, '');
    return callback(formattedMessageID === id, formattedMessageID);
  });
};