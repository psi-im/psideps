#!/bin/sh
set -e

base_prefix=$1

if [ -z "$base_prefix" ]; then
        echo "usage: $0 [prefix]"
        exit 1
fi

base_prefix=$base_prefix/i386

VERSION=0.10.36
dist_base=dist/gstreamer-$VERSION-mac
rm -rf $dist_base

echo "setting up $dist_base"

mkdir -p $dist_base
mkdir -p $dist_base/bin
mkdir -p $dist_base/include
mkdir -p $dist_base/lib
mkdir -p $dist_base/libexec

BIN_FILES="glib-compile-resources glib-compile-schemas glib-gettextize glib-genmarshal glib-mkenums gst-inspect-0.10 gst-launch-0.10 gst-feedback-0.10 gst-typefind-0.10 gst-visualise-0.10 gst-xmlinspect-0.10"

for n in $BIN_FILES; do
	cp -a $base_prefix/bin/$n $dist_base/bin
done

cp -a $base_prefix/include/glib-2.0 $dist_base/include
cp -a $base_prefix/include/gstreamer-0.10 $dist_base/include

cp -a $base_prefix/lib/glib-2.0 $dist_base/lib
cp -a $base_prefix/lib/*.a $dist_base/lib
cp -a $base_prefix/lib/*.dylib $dist_base/lib
mkdir $dist_base/lib/gstreamer-0.10
cp -a $base_prefix/lib/gstreamer-0.10/*.so $dist_base/lib/gstreamer-0.10

cp -a $base_prefix/libexec/gstreamer-0.10 $dist_base/libexec

cp -a distfiles/mac/README $dist_base

LIB_FILES_FIND=`find $dist_base/lib -type f -name \*.dylib`
LIB_FILES=
for n in $LIB_FILES_FIND; do
	LIB_FILES="$LIB_FILES `basename $n`"
done

EXE_FILES="glib-compile-resources glib-compile-schemas glib-genmarshal gst-inspect-0.10 gst-launch-0.10 gst-typefind-0.10 gst-xmlinspect-0.10"

for n in $EXE_FILES; do
	for i in $LIB_FILES; do
		install_name_tool -change $base_prefix/lib/$i $i $dist_base/bin/$n
	done
done

LIBEXE_FILES="gst-plugin-scanner"

for n in $LIBEXE_FILES; do
	for i in $LIB_FILES; do
		install_name_tool -change $base_prefix/lib/$i $i $dist_base/libexec/gstreamer-0.10/$n
	done
done

for n in $LIB_FILES; do
	install_name_tool -id $n $dist_base/lib/$n
	for i in $LIB_FILES; do
		install_name_tool -change $base_prefix/lib/$i $i $dist_base/lib/$n
	done
done

echo "creating gstreamer-$VERSION-mac.tar.bz2"

cd dist
tar jcf ../gstreamer-$VERSION-mac.tar.bz2 gstreamer-$VERSION-mac
