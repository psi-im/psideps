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

build_package_qca() {
	if [ "$target_arch" == "x86_64" ]; then
		qtdir=$QTDIR64
	else
		qtdir=$QTDIR32
	fi
	mqtdir=`get_msys_path $qtdir`
	tar jxvf $pkgdir/$qca_file
	cd qca-*
	patch -p0 < $patchdir/gcc_4.7_fix.diff
	PATH=$mqtdir/bin:$PATH ./configure.exe --qtdir=$qtdir --release
	mingw32-make
	cp -r bin $arch_prefix
	cp -r include $arch_prefix
	cp -r lib $arch_prefix
}

build_package $package_name $target_arch
