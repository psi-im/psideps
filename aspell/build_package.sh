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

build_package_aspell() {
	tar zxvf $pkgdir/$aspell_file
	cd aspell-*
	patch -p0 < $patchdir/asc_ctype_fix.diff
	patch -p1 < $patchdir/namespace_fix.diff
	if [ "$target_arch" == "x86_64" ]; then
		./configure --prefix=$arch_prefix
	else
		# seems we need to set location of objdump on i386
		OBJDUMP=/mingw/bin/objdump ./configure --prefix=$arch_prefix
	fi
	make
	make install
}

build_package_aspell_en() {
	tar jxvf $pkgdir/$aspell_en_file
	cd aspell6-*
	./configure --vars ASPELL=$arch_prefix/bin/aspell PREZIP=$arch_prefix/bin/prezip-bin
	ASPELL_CONF="prefix /mingw/msys/1.0$arch_prefix" make
	make install
}

build_package $package_name $target_arch
