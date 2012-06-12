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

if [ "$target_arch" == "x86_64" ]; then
	export PATH=/c/mingw64/bin:$PATH
fi

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

build_package_openssl() {
	tar zxvf $pkgdir/$openssl_file
	cd openssl-*
	if [ "$target_arch" == "x86_64" ]; then
		./Configure --with-zlib-include=$base_prefix/../zlib/$target_arch/include --with-zlib-lib=$base_prefix/../zlib/$target_arch/lib shared zlib mingw64
	else
		./config --with-zlib-include=$base_prefix/../zlib/$target_arch/include --with-zlib-lib=$base_prefix/../zlib/$target_arch/lib shared zlib
	fi
	make
	mkdir -p $arch_prefix/bin
	mkdir -p $arch_prefix/include
	mkdir -p $arch_prefix/lib
	cp libeay32.dll ssleay32.dll apps/openssl.exe $arch_prefix/bin
	cp -r include/openssl $arch_prefix/include
	cp libcrypto.dll.a libssl.dll.a $arch_prefix/lib
}

build_package $package_name $target_arch
