#!/bin/bash

git remote add self .
git fetch self

rm -rf DD
git checkout -f
rm -rf ~/Library/Caches/XCRemoteCache/localhost

# start ngingx
sudo nginx -s stop
sudo nginx -c $PWD/nginx.conf 

# reset stats
XCRC/xcprepare stats --reset

## Producer
XCRC/xcprepare integrate --input Hybrid.xcodeproj --mode producer --final-producer-target Hybrid
xcodebuild EXCLUDED_ARCHS=x86_64  -project Hybrid.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 12' -scheme Hybrid  -sdk "iphonesimulator" -derivedDataPath DD > build.log

## print & reset stats
XCRC/xcprepare stats
XCRC/xcprepare stats --reset

## Consumer
XCRC/xcprepare integrate --input Hybrid.xcodeproj --mode consumer --final-producer-target Hybrid
xcodebuild EXCLUDED_ARCHS=x86_64 -project Hybrid.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 12' -scheme Hybrid -sdk "iphonesimulator" -derivedDataPath  DD > build.log

## print stats
XCRC/xcprepare stats
XCRC/xcprepare stats --reset

# Modify the Swift file to force to local compilation
sed -i '' 's/print/ print/' Hybrid/ViewController.swift 
# Modify history.compile to fail a build if that history is actually relevant (invoked)
LC_CTYPE=C LANG=C sed -i '' 's/clang/nonexisting/' DD/Build/Intermediates.noindex/Hybrid.build/Debug-iphonesimulator/Hybrid.build/history.compile 

# Build and see if any ObjC step is invoked from Xcode
xcodebuild -project Hybrid.xcodeproj -destination 'generic/platform=iOS Simulator' -scheme Hybrid -sdk "iphonesimulator" -derivedDataPath DD | tee build.log | grep CompileC

XCRC/xcprepare stats

## stop nginx (temporarly disabled)
# sudo nginx -s stop