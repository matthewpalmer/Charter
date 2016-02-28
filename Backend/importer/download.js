const https = require('https');
const fs = require('fs');
const path = require('path');
const async = require('async');
const moment = require('moment');
const listPeriod = require('../list-period');

function getQueryDates() {
  const startDate = new Date('November 30, 2015 12:30:00');
  const endDate = new Date('February 28, 2016 12:30:00');

  const m = moment(startDate);
  const endMoment = moment(endDate);

  var dates = [];
  while (m.isBefore(endMoment)) {
    dates.push(m.toISOString());
    m = m.add(7, 'days');
  }

  return dates;
}

function getPeriods(list) {
  return getQueryDates().map(d => new Date(d)).map(d => listPeriod(list, d));
}

// https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160222.txt.gz

function getURLs(list) {
  return getPeriods(list).map(period => {
    return `https://lists.swift.org/pipermail/${list}/${period}.txt.gz`;
  });
}

function downloadAndWriteFile(path, URL, callback) {
  const file = fs.createWriteStream(path);
  console.log(`Downloading ${URL} to ${path}...`);
  const request = https.get(URL, function(response) {
    response.pipe(file);
    file.on('finish', () => {
      file.close(callback);
    })
  });
}

function downloadURLs(outputDirectory, URLs, callback) {
  if (!fs.existsSync(outputDirectory)){
      fs.mkdirSync(outputDirectory);
  }

  async.each(URLs, (URL, callback) => {
    const file = path.join(outputDirectory, path.basename(URL));
    downloadAndWriteFile(file, URL, callback);
  }, (err) => {
    callback(err);
  });
}

const outputDirectory = process.argv[2];

if (!outputDirectory) {
  console.error('Usage: node download.js $outputDirectory.');
  return;
}

async.each([/*'swift-evolution', */'swift-users'/*, 'swift-dev'*/], (list, callback) => {
  downloadURLs(path.join(outputDirectory, list), getURLs(list), callback);
}, (err) => {
  if (err) {
    console.error(err);
  } else {
    console.log('Finished.');
  }
});
