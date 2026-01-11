#!/bin/bash

# Rebuilds luajit (for updated lovely builds) and cleans gradle
OPWD="$PWD"
cd love/src/jni/LuaJIT-2.1/

./build.fish

cd "$OPWD"

./gradlew clean
