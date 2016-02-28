This module is responsible for downloading, extracting, and formatting archival data from the lists.swift.org website.

`$archives` is the directory where you want to download the archival emails. `$output` is the directory where you want the resulting JSON files.


    ./run.sh $archives $output


1. Download data: `node download.js $archives`
2. Unzip data: `gunzip -kf $archives/**/*.gz`
3. Generate JSON: `node generate.js $archives $json`
