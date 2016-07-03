/*

This is the main script for creating a JSON file that can be imported into
the database. It expects the following structure. $data_directory is the
directory you pass on the command line. It may vary. Everything else is
not designed to be tweaked, and expects data in a format loosely copying that
of the lists.swift.org website. We will (hopefully remember to)
provide scripts to download that data, so check the README for those.

  - $data_directory/
    - swift-evolution/
      - Week-of-Mon-20151207.txt
      - Week-of-...txt
      - Week-of-...txt
    - swift-users/
      - Week-of-Mon-20151207.txt
      - Week-of-...txt
      - Week-of-...txt
    - swift-dev/
      - Week-of-Mon-20151207.txt
      - Week-of-...txt
      - Week-of-...txt

This script will write the contents of the JSON to the directory specified,
using the mailing list identifiers as file names.

node generate.js $data_directory $output_directory

*/

const commandLineArgs = require('command-line-args');
const glob = require('glob');
const path = require('path');
const fs = require('fs');
const async = require('async');
const listParser = require('./list-parser');

const getTestFile = (name, callback) => {
  fs.readFile(path.join(__dirname, 'sample', name), 'utf8', callback);
};

const mailingLists = ['swift-evolution', 'swift-users', 'swift-dev', 'swift-build-dev'];

function run(dataDirectory, outputDirectory) {
  async.each(mailingLists, (list, callback) => {
    const files = glob(path.join(dataDirectory, list, '*.txt'), (err, files) => {
      async.concat(files, parseFile(list), (err, listElements) => {
        fs.writeFile(path.join(outputDirectory, list + '.json'), JSON.stringify(listElements), (e) => {
          if (e) {
            console.log(e);
          } else {
            console.log(list, '— ✔︎');
          }
          callback(e);
        });
      });
    });
  });
}

const parseFile = (list) => (file, callback) => {
  fs.readFile(file, 'utf8', (err, message) => {
    listParser(message, (err, formattedMessages) => {
      formattedMessages = formattedMessages
        .map(x => reformatMessage(file, list, x));

      callback(null, formattedMessages);
    });
  });
};

const reformatMessage = (file, mailingList, formattedMessage) => {
  formattedMessage.mailingList = mailingList;
  formattedMessage._id = formattedMessage.messageID;
  delete formattedMessage.messageID;
  return formattedMessage;
}

const dataDirectory = process.argv[2];
const outputDirectory = process.argv[3];

if (!dataDirectory || !outputDirectory) {
  console.error('Usage: node generate.js $dataDirectory $outputDirectory. See top of file for info.');
  return;
}

run(dataDirectory, outputDirectory);
