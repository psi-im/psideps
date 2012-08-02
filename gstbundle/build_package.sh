#!/bin/sh
set -e

if [ $# != 4 ]; then
	echo "usage: $0 [package] [arch] [prefix] [destdir]"
	exit 1
fi

platform=`uname -s`
if [ "$platform" == "Darwin" ]; then
	platform=mac
elif [ "$platform" == "MINGW32_NT-6.1" ]; then
	platform=win
else
	echo "error: unsupported platform $platform"
	exit 1
fi

source ./package_info

package_name=$1
target_arch=$2
base_prefix=$3
destdir=$4

if [ "$platform" == "mac" ]; then
	target_platform=$target_arch-apple-darwin
	export MACOSX_DEPLOYMENT_TARGET=10.5
else
	if [ "$target_arch" == "x86_64" ]; then
		export PATH=/c/mingw64/bin:$PATH
	fi
fi

arch_prefix=$base_prefix/$target_arch
pkgdir=$PWD/packages
patchdir=$PWD/patches

export PATH=$base_prefix/../zlib/$target_arch/bin:$arch_prefix/bin:$PATH

# make the install dir and ensure we can write to it
mkdir -p $arch_prefix
touch $arch_prefix/test_writable
rm $arch_prefix/test_writable

check_race_cond() {
	if find . -name config.log | xargs grep "Permission denied" > /dev/null; then
		echo "error: file access race condition. try again."
		exit 1
	fi
}

build_package() {
	if [ ! -d "build/$2/$1" ]; then
		echo "$1/$2: building..."
		mkdir -p build/$2/$1
		old_pwd=$PWD
		cd build/$2/$1
		build_package_$1
		cd $old_pwd
	else
		echo "$1/$2: failed on previous run. remove the \"build/$2/$1\" directory to try again"
		exit 1
	fi
}

build_package_libiconv() {
	tar zxvf $pkgdir/$libiconv_file
	cd libiconv-*
	./configure --prefix=$arch_prefix
	check_race_cond
	make
	make install
}

build_package_libffi() {
	tar zxvf $pkgdir/$libffi_file
	cd libffi-*
	if [ "$platform" == "win" ] && [ "$target_arch" == "x86_64" ]; then
		./configure --build=x86_64-pc-mingw32 --prefix=$arch_prefix
		cp x86_64-pc-mingw32/libtool x86_64-pc-mingw32/libtool.orig
		sed -e "s/allow_undefined_flag=\"unsupported\"/allow_undefined_flag=/g" x86_64-pc-mingw32/libtool.orig > x86_64-pc-mingw32/libtool
	else
		./configure --prefix=$arch_prefix
	fi
	check_race_cond
	make
	make install
}

build_package_gettext() {
	tar zxvf $pkgdir/$gettext_file
	cd gettext-*
	if [ "$platform" == "mac" ]; then
		CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	else
		if [ "$target_arch" == "x86_64" ]; then
			#patch -p1 < $patchdir/gettext_vasprintf_conflict.diff
			patch -p1 < $patchdir/gettext_export_win64.diff
			patch -p1 < $patchdir/gettext_ostream_win64.diff
			echo "patching configure to be really slow"
			for cf in `find . -name configure`; do
				cp $cf ${cf}.orig
				sed -e "s/^ac_link='/ac_link='sleep 1 \&\& /g" ${cf}.orig > $cf
			done
			CFLAGS=-I$arch_prefix/include CXXFLAGS=-I$arch_prefix/include LDFLAGS=-L$arch_prefix/lib ./configure --prefix=$arch_prefix --with-libiconv-prefix=$arch_prefix --enable-threads=win32
		else
			./configure --prefix=$arch_prefix --with-libiconv-prefix=$arch_prefix --enable-threads=win32
		fi
	fi
	check_race_cond
	make
	make install
}

build_package_glib() {
	tar jxvf $pkgdir/$glib_file
	cd glib-*
	if [ "$platform" == "mac" ]; then
		CFLAGS=-I$arch_prefix/include LDFLAGS=-L$arch_prefix/lib LIBFFI_CFLAGS=-I/Developer/SDKs/MacOSX10.5.sdk/usr/include/ffi LIBFFI_LIBS=-lffi CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	else
		patch -p0 < $patchdir/glib_nopython.diff
		if [ "$target_arch" == "x86_64" ]; then
			patch -p0 < $patchdir/glib_confrace.diff
			ZLIB_CFLAGS=-I$base_prefix/../zlib/$target_arch/include ZLIB_LIBS="-L$base_prefix/../zlib/$target_arch/lib -lz.dll" LIBFFI_CFLAGS=-I$arch_prefix/lib/libffi-3.0.10/include LIBFFI_LIBS="-L$arch_prefix/lib -lffi.dll" CFLAGS=-I$arch_prefix/include LDFLAGS="-L$arch_prefix/lib" ./configure --prefix=$arch_prefix
		else
			ZLIB_CFLAGS=-I$base_prefix/../zlib/$target_arch/include ZLIB_LIBS="-L$base_prefix/../zlib/$target_arch/lib -lz.dll" LIBFFI_CFLAGS=-I$arch_prefix/lib/libffi-3.0.10/include LIBFFI_LIBS="-L$arch_prefix/lib -lffi.dll" CFLAGS=-I$arch_prefix/include LDFLAGS="-L$arch_prefix/lib" CC="gcc -march=i686 -mthreads" ./configure --prefix=$arch_prefix
		fi
	fi
	check_race_cond
	make
	make install
}

build_package_pkgconfig() {
	tar zxvf $pkgdir/$pkgconfig_file
	cd pkg-config-*
	if [ "$platform" == "mac" ]; then
		GLIB_CFLAGS="-I$arch_prefix/lib/glib-2.0/include -I$arch_prefix/include/glib-2.0" GLIB_LIBS="-L$arch_prefix/lib -lglib-2.0" CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	else
		patch -p1 < $patchdir/pkgconfig_latest_glib.diff
		GLIB_CFLAGS="-I$arch_prefix/lib/glib-2.0/include -I$arch_prefix/include/glib-2.0" GLIB_LIBS="-L$arch_prefix/lib -lglib-2.0" ./configure --prefix=$arch_prefix
	fi
	check_race_cond
	make
	make install
}

build_package_libjpeg() {
	tar zxvf $pkgdir/$libjpeg_file
	cd jpeg-6b
	if [ "$platform" == "mac" ]; then
		CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	else
		./configure --prefix=$arch_prefix
	fi
	check_race_cond
	make
	cp jerror.h jconfig.h jmorecfg.h jpeglib.h $arch_prefix/include
	cp libjpeg.a $arch_prefix/lib
}

build_package_libogg() {
	tar zxvf $pkgdir/$libogg_file
	cd libogg-*
	if [ "$platform" == "mac" ]; then
		CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	else
		./configure --prefix=$arch_prefix
	fi
	check_race_cond
	make
	make install
}

build_package_libvorbis() {
	tar jxvf $pkgdir/$libvorbis_file
	cd libvorbis-*
	if [ "$platform" == "mac" ]; then
		CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	else
		./configure --prefix=$arch_prefix
	fi
	check_race_cond
	make
	make install
}

build_package_libtheora() {
	tar jxvf $pkgdir/$libtheora_file
	cd libtheora-*
	if [ "$platform" == "mac" ]; then
		CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	else
		./configure --prefix=$arch_prefix
	fi
	check_race_cond
	make
	make install
}

build_package_libspeex() {
	tar zxvf $pkgdir/$libspeex_file
	cd speex-*
	if [ "$platform" == "mac" ]; then
		CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix
	else
		./configure --prefix=$arch_prefix
	fi
	check_race_cond
	make
	make install
}

build_package_gstreamer() {
	tar jxvf $pkgdir/$gstreamer_file
	cd gstreamer-*
	if [ "$platform" == "mac" ]; then
		CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix --disable-loadsave
	else
		./configure --prefix=$arch_prefix --disable-loadsave
		if [ "$target_arch" == "x86_64" ]; then
			# pthread needs to be linked for monotonic clock
			cp gst/Makefile gst/Makefile.orig
			sed -e "s/\(GST_ALL_LIBS .*\)/\1 -lpthread/g" gst/Makefile.orig > gst/Makefile
		fi
	fi
	check_race_cond
	make
	make install
}

build_package_gstbase() {
	tar jxvf $pkgdir/$gstbase_file
	cd gst-plugins-base-*
	patch -p1 < $patchdir/audiosync_fix.diff
	if [ "$platform" == "mac" ]; then
		CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix

		# workaround gcc 4.2.1 bugs on mac by disabling optimizations
		cp gst/audioconvert/Makefile gst/audioconvert/Makefile.orig
		sed -e "s/CFLAGS = -g -O2/CFLAGS = -g/g" gst/audioconvert/Makefile.orig > gst/audioconvert/Makefile
		cp gst/volume/Makefile gst/volume/Makefile.orig
		sed -e "s/CFLAGS = -g -O2/CFLAGS = -g/g" gst/volume/Makefile.orig > gst/volume/Makefile
	else
		./configure --prefix=$arch_prefix
	fi
	check_race_cond
	make
	make install
}

build_package_gstgood() {
	tar jxvf $pkgdir/$gstgood_file
	cd gst-plugins-good-*
	patch -p1 < $patchdir/udp_noipv6.diff
	if [ "$platform" == "mac" ]; then
		CFLAGS=-I$arch_prefix/include LDFLAGS=-L$arch_prefix/lib CC="gcc -arch $target_arch" CXX="g++ -arch $target_arch" ./configure --host=$target_platform --prefix=$arch_prefix --disable-osx_video
	else
		if [ "$target_arch" == "x86_64" ]; then
			CFLAGS=-I$arch_prefix/include LDFLAGS=-L$arch_prefix/lib ./configure --prefix=$arch_prefix --disable-directsound --disable-goom
		else
			CFLAGS=-I$arch_prefix/include LDFLAGS=-L$arch_prefix/lib ./configure --prefix=$arch_prefix --disable-directsound
		fi
	fi
	check_race_cond
	make
	make install
}

build_package $package_name $target_arch
