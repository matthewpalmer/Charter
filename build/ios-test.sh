#!/usr/bin/env sh
echo $PWD; cd iOS/Charter && xctool -sdk iphonesimulator -workspace Charter.xcworkspace -scheme "Charter" -destination "platform=iOS Simulator,name=iPhone 6,OS=9.2" test && cd ..;