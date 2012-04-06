#!/bin/sh
set -e

source ./package_info

base_prefix=$1

if [ -z "$base_prefix" ]; then
	echo "usage: $0 [prefix]"
	exit 1
fi

PACKAGES="gettext glib pkgconfig libjpeg libogg libvorbis libtheora libspeex gstreamer gstbase gstgood"

base_prefix=$base_prefix/i386

export MACOSX_DEPLOYMENT_TARGET=10.5
export PATH=$PATH:$base_prefix/bin

build_package() {
	if [ ! -d "build/$1" ]; then
		echo "$1: building..."
		mkdir -p build/$1
		OLD_PWD=$PWD
		cd build/$1
		build_package_$1
		cd $OLD_PWD
		touch "build/$1/ok"
	else
		if [ ! -f "build/$1/ok" ]; then
			echo "$1: failed on previous run. remove the \"build/$1\" directory to try again"
			exit 1
		else
			echo "$1: already built"
		fi
	fi
}

build_package_gettext() {
	tar zxvf ../../packages/$gettext_file
	cd gettext-*
	CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix
	make && make install
}
build_package gettext

build_package_glib() {
	tar jxvf ../../packages/$glib_file
	cd glib-*
	CFLAGS=-I$base_prefix/include LDFLAGS=-L$base_prefix/lib LIBFFI_CFLAGS=-I/Developer/SDKs/MacOSX10.5.sdk/usr/include/ffi LIBFFI_LIBS=-lffi CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix
	make && make install
}
build_package glib

build_package_pkgconfig() {
	tar zxvf ../../packages/$pkgconfig_file
	cd pkg-config-*
	GLIB_CFLAGS="-I$base_prefix/lib/glib-2.0/include -I$base_prefix/include/glib-2.0" GLIB_LIBS="-L$base_prefix/lib -lglib-2.0" CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix
	make && make install
}
build_package pkgconfig

build_package_libjpeg() {
	tar zxvf ../../packages/$libjpeg_file
	cd jpeg-6b
	CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix
	make
	cp jerror.h jconfig.h jmorecfg.h jpeglib.h $base_prefix/include
	cp libjpeg.a $base_prefix/lib
}
build_package libjpeg

build_package_libogg() {
	tar zxvf ../../packages/$libogg_file
	cd libogg-*
	CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix
	make && make install
}
build_package libogg

build_package_libvorbis() {
	tar zxvf ../../packages/$libvorbis_file
	cd libvorbis-*
	CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix
	make && make install
}
build_package libvorbis

build_package_libtheora() {
	tar zxvf ../../packages/$libtheora_file
	cd libtheora-*
	CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix
	make && make install
}
build_package libtheora

build_package_libspeex() {
	tar zxvf ../../packages/$libspeex_file
	cd speex-*
	CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix
	make && make install
}
build_package libspeex

build_package_gstreamer() {
	tar zxvf ../../packages/$gstreamer_file
	cd gstreamer-*
	CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix --disable-loadsave
	make && make install
}
build_package gstreamer

build_package_gstbase() {
	tar zxvf ../../packages/$gstbase_file
	cd gst-plugins-base-*
	CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix

	# fix sync bug in 0.10.36
	patch -p1 < ../../../patches/audiosync_fix.diff

	# workaround gcc 4.2.1 bugs on mac by disabling optimizations
	cp gst/audioconvert/Makefile gst/audioconvert/Makefile.orig
	sed -e "s/CFLAGS = -g -O2/CFLAGS = -g/g" gst/audioconvert/Makefile.orig > gst/audioconvert/Makefile
	cp gst/volume/Makefile gst/volume/Makefile.orig
	sed -e "s/CFLAGS = -g -O2/CFLAGS = -g/g" gst/volume/Makefile.orig > gst/volume/Makefile

	make && make install
}
build_package gstbase

build_package_gstgood() {
	tar zxvf ../../packages/$gstgood_file
	cd gst-plugins-good-*
	patch -p1 < ../../../patches/udp_noipv6.diff
	CFLAGS=-I$base_prefix/include LDFLAGS=-L$base_prefix/lib CC="gcc -arch i386" CXX="g++ -arch i386" ./configure --host=i386-apple-darwin --prefix=$base_prefix --disable-osx_video
	make && make install
}
build_package gstgood
