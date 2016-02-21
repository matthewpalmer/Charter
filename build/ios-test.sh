#!/usr/bin/env sh
echo $PWD; cd iOS/Charter && xctool -sdk iphonesimulator -workspace Charter.xcworkspace -scheme "Swift Mailing List" test && cd ..;