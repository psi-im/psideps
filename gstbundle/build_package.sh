#!/bin/sh
set -e

if [ $# != 4 ]; then
	echo "usage: $0 [package] [arch] [prefix] [destdir]"
	exit 1
fi

source ./package_info

package_name=$1
target_arch=$2
base_prefix=$3
destdir=$4

target_platform=$target_arch-apple-darwin
arch_prefix=$base_prefix/$target_arch
pkgdir=$PWD/packages
patchdir=$PWD/patches

export MACOSX_DEPLOYMENT_TARGET=10.5
export PATH=$arch_prefix/bin:$PATH

# make the install dir and ensure we can write to it
mkdir -p $arch_prefix
touch $arch_prefix/test_writable
rm $arch_prefix/test_writable

build_package() {
	if [ ! -d "build/$2/$1" ]; then
		echo "$1/$2: building..."
		mkdir -p build/$2/$1
		old_pwd=$PWD
		cd build/$2/$1
		build_package_$1
		cd $old_pwd
		touch "build/$2/$1/ok"
	else
		echo "$1/$2: failed on previous run. remove the \"build/$2/$1\" directory to try again"
		exit 1
	fi
}

build_package_gettext() {
	tar zxvf $pkgdir/$gettext_file
	cd gettext-*
	CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	make
	make install
}

build_package_glib() {
	tar jxvf $pkgdir/$glib_file
	cd glib-*
	CFLAGS=-I$arch_prefix/include LDFLAGS=-L$arch_prefix/lib LIBFFI_CFLAGS=-I/Developer/SDKs/MacOSX10.5.sdk/usr/include/ffi LIBFFI_LIBS=-lffi CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	make
	make install
}

build_package_pkgconfig() {
	tar zxvf $pkgdir/$pkgconfig_file
	cd pkg-config-*
	GLIB_CFLAGS="-I$arch_prefix/lib/glib-2.0/include -I$arch_prefix/include/glib-2.0" GLIB_LIBS="-L$arch_prefix/lib -lglib-2.0" CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	make
	make install
}

build_package_libjpeg() {
	tar zxvf $pkgdir/$libjpeg_file
	cd jpeg-6b
	CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	make
	cp jerror.h jconfig.h jmorecfg.h jpeglib.h $arch_prefix/include
	cp libjpeg.a $arch_prefix/lib
}

build_package_libogg() {
	tar zxvf $pkgdir/$libogg_file
	cd libogg-*
	CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	make
	make install
}

build_package_libvorbis() {
	tar zxvf $pkgdir/$libvorbis_file
	cd libvorbis-*
	CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	make
	make install
}

build_package_libtheora() {
	tar zxvf $pkgdir/$libtheora_file
	cd libtheora-*
	CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	make
	make install
}

build_package_libspeex() {
	tar zxvf $pkgdir/$libspeex_file
	cd speex-*
	CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	make
	make install
}

build_package_gstreamer() {
	tar zxvf $pkgdir/$gstreamer_file
	cd gstreamer-*
	CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix --disable-loadsave
	make
	make install
}

build_package_gstbase() {
	tar zxvf $pkgdir/$gstbase_file
	cd gst-plugins-base-*
	CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix

	# fix sync bug in 0.10.36
	patch -p1 < $patchdir/audiosync_fix.diff

	# workaround gcc 4.2.1 bugs on mac by disabling optimizations
	cp gst/audioconvert/Makefile gst/audioconvert/Makefile.orig
	sed -e "s/CFLAGS = -g -O2/CFLAGS = -g/g" gst/audioconvert/Makefile.orig > gst/audioconvert/Makefile
	cp gst/volume/Makefile gst/volume/Makefile.orig
	sed -e "s/CFLAGS = -g -O2/CFLAGS = -g/g" gst/volume/Makefile.orig > gst/volume/Makefile

	make
	make install
}

build_package_gstgood() {
	tar zxvf $pkgdir/$gstgood_file
	cd gst-plugins-good-*
	patch -p1 < $patchdir/udp_noipv6.diff
	CFLAGS=-I$arch_prefix/include LDFLAGS=-L$arch_prefix/lib CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix --disable-osx_video
	make
	make install
}

build_package $package_name $target_arch
