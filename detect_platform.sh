#!/bin/sh

if [ -z "$PLATFORM" ]; then
  platform=`uname -s`
  if [ "$platform" == "Darwin" ]; then
    platform=mac
  elif [ "$platform" == "MINGW32_NT-6.1" ]; then
    platform=win
  else
    echo "error: unsupported platform $platform"
    exit 1
  fi
else
  platform="$PLATFORM"
fi

if [ "$platform" == "mac" ]; then
	export MACOSX_DEPLOYMENT_TARGET=10.10
fi
