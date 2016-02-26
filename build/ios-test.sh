#!/usr/bin/env sh
echo $PWD; cd iOS/Charter && xctool -sdk iphonesimulator -workspace Charter.xcworkspace -scheme "Charter" test && cd ..;
