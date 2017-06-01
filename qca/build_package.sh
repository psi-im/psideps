#!/bin/sh
set -e

if [ $# != 4 ]; then
	echo "usage: $0 [package] [arch] [prefix] [destdir]"
	exit 1
fi

. ../detect_platform.sh
source ./package_info

package_name=$1
target_arch=$2
base_prefix=$3
destdir=$4

if [ "$platform" == "mac" ]; then
	target_platform=$target_arch-apple-darwin
else
	if [ "$target_arch" == "x86_64" ]; then
		export PATH=/c/mingw64/bin:$PATH
	fi
fi

if [ "$target_arch" != "" ]; then
	arch_prefix=$base_prefix/$target_arch
else
	arch_prefix=$base_prefix
fi
pkgdir=$PWD/packages
patchdir=$PWD/patches

# make the install dir and ensure we can write to it
mkdir -p $arch_prefix
touch $arch_prefix/test_writable
rm $arch_prefix/test_writable

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
	tar jxvf $pkgdir/$qca_file
	cd qca-*
	qca_args="-DQT4_BUILD=OFF -DWITH_ossl_PLUGIN=yes -DWITH_gnupg_PLUGIN=yes -DBUILD_TESTS=no "
	if [ "$platform" == "win" ]; then
		if [ "$target_arch" == "x86_64" ]; then
			qtdir=$QTDIR64
		else
			qtdir=$QTDIR32
		fi
		mqtdir=`get_msys_path $qtdir`
		cmake $qca_args -DWITH_wingss_PLUGIN=yes
		mingw32-make
		cp -r bin $arch_prefix
		cp -r include $arch_prefix
		cp -r lib $arch_prefix
	else
		cmake $qca_args -DCMAKE_INSTALL_PREFIX=$arch_prefix
		make
		make install
	fi
}

if [ "$target_arch" != "" ]; then
	build_package $package_name $target_arch
else
	build_package $package_name uni
fi
