#!/usr/bin/env sh

# Add contributors to README
perl -i -0777 -pe 's/## Contributors.*//igs' README.md
cat 'Documentation Resources/CONTRIBUTORS' >> README.md

# Add contributors to release notes
cat 'Documentation Resources/CONTRIBUTORS' \
| grep /^\*/\
| perl -pe 's/...([\w\s]+).* — (.*).*/\nHuge thanks to everyone who has contributed to the Charter open source project:\n\n— $1, $2/g' \
>> 'iOS/Charter/fastlane/metadata/en-US/release_notes.txt'
