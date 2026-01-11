#!/bin/bash

# NOTE: if you rebuild lovely need to clean build
./gradlew assembleEmbedNorecordRelease

cp app/build/outputs/apk/embedNoRecord/release/app-embed-noRecord-release.apk base.apk 
