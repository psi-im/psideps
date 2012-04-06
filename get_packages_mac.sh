#!/bin/sh

source ./package_info

WGET=`which wget`
if [ ! -z "$WGET" ]; then
	FETCH_CMD="$WGET"
else
	CURL=`which curl`
	if [ ! -z "$CURL" ]; then
		FETCH_CMD="$CURL -O"
	else
		echo "error: need wget or curl in path"
		exit 1
	fi
fi

mkdir -p packages
cd packages

PACKAGES="gettext glib pkgconfig libjpeg libogg libvorbis libtheora libspeex gstreamer gstbase gstgood"

for p in $PACKAGES; do
	p_file=`eval echo \\$${p}_file`
	p_url=`eval echo \\$${p}_url`
	if [ ! -f "$p_file" ]; then
		echo $FETCH_CMD $p_url
		$FETCH_CMD $p_url
	else
		echo "already have $p_file, skipping"
	fi
done
