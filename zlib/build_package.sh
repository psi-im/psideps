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

target_platform=$target_arch-mingw32-gcc
arch_prefix=$base_prefix/$target_arch
pkgdir=$PWD/packages
patchdir=$PWD/patches

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
	else
		echo "$1/$2: failed on previous run. remove the \"build/$2/$1\" directory to try again"
		exit 1
	fi
}

build_package_zlib() {
	tar jxvf $pkgdir/$zlib_file
	cd zlib-*
	make -f win32/Makefile.gcc
	make -p $arch_prefix/bin
	make -p $arch_prefix/include
	make -p $arch_prefix/lib
	cp zlib1.dll $arch_prefix/bin
	cp zconf.h zlib.h $arch_prefix/include
	cp libz.dll.a $arch_prefix/lib
}

build_package $package_name $target_arch
