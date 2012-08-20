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

# make the install dir and ensure we can write to it
mkdir -p $arch_prefix
touch $arch_prefix/test_writable
rm $arch_prefix/test_writable

export PATH=$base_prefix/../zlib/$target_arch/bin:$base_prefix/../gstbundle/$target_arch/bin:$PATH

get_msys_path() {
	if [ `expr index $1 :` -gt 0 ]; then
		pdrive=`echo $1 | cut -f 1 --delimiter=:`
		prest=`echo $1 | cut -f 2 --delimiter=:`
		echo /$pdrive$prest
	else
		echo $1
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

build_package_psimedia() {
	tar jxvf $pkgdir/$psimedia_file
	cd psimedia-*
	patch -p1 < $patchdir/disable_video.diff
	patch -p1 < $patchdir/osxaudio_fixedrate.diff
	if [ "$platform" == "win" ]; then
		if [ "$target_arch" == "x86_64" ]; then
			qtdir=$QTDIR64
		else
			qtdir=$QTDIR32
		fi
		mqtdir=`get_msys_path $qtdir`

		if [ "$target_arch" == "x86_64" ]; then
			cp $patchdir/gstconf_w64.pri gstprovider/gstconf.pri
		else
			cp $patchdir/gstconf_w32.pri gstprovider/gstconf.pri
		fi

		echo "CONFIG -= debug_and_release debug release" >> demo/demo.pro
		echo "CONFIG += release" >> conf.pri
		echo "CONFIG += release" >> demo/demo.pro

		$mqtdir/bin/qmake
		mingw32-make

		# build shared plugins too
		cd gstprovider/gstelements/shared
		$mqtdir/bin/qmake
		mingw32-make
		cd ../../..

		mkdir -p $arch_prefix/demo
		mkdir -p $arch_prefix/plugins
		mkdir -p $arch_prefix/gstreamer-0.10
		cp demo/demo.exe $arch_prefix/demo
		cp gstprovider/gstprovider.dll $arch_prefix/plugins
		cp gstprovider/gstelements/shared/lib/*.dll $arch_prefix/gstreamer-0.10
	else
		./configure --release
		if [ "$target_arch" == "x86_64" ]; then
			echo "contains(QT_CONFIG,x86_64):CONFIG += x86_64" >> conf.pri
			echo "contains(QT_CONFIG,x86_64):CONFIG += x86_64" >> demo/demo.pro 
		else
			echo "contains(QT_CONFIG,x86):CONFIG += x86" >> conf.pri
			echo "contains(QT_CONFIG,x86):CONFIG += x86" >> demo/demo.pro
		fi
		echo "QMAKE_MAC_SDK = /Developer/SDKs/MacOSX10.5.sdk" >> conf.pri
		echo "QMAKE_MAC_SDK = /Developer/SDKs/MacOSX10.5.sdk" >> demo/demo.pro
		$QTDIR/bin/qmake
		make

		# build shared plugins too
		cd gstprovider/gstelements/shared
		$QTDIR/bin/qmake
		make
		cd ../../..

		mkdir -p $arch_prefix/demo
		mkdir -p $arch_prefix/plugins
		mkdir -p $arch_prefix/gstreamer-0.10
		cp demo/demo $arch_prefix/demo
		cp gstprovider/libgstprovider.dylib $arch_prefix/plugins
		cp gstprovider/gstelements/shared/lib/*.dylib $arch_prefix/gstreamer-0.10
	fi
}

build_package $package_name $target_arch
