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
	if [ "$platform" == "win" ]; then
		if [ "$target_arch" == "x86_64" ]; then
			qtdir=$QTDIR64
		else
			qtdir=$QTDIR32
		fi
		mqtdir=`get_msys_path $qtdir`
		cp $patchdir/configure.exe .
		patch -p0 < $patchdir/gcc_4.7_fix.diff
		PATH=$mqtdir/bin:$PATH ./configure.exe --qtdir=$qtdir --release
		mingw32-make
		cp -r bin $arch_prefix
		cp -r include $arch_prefix
		cp -r lib $arch_prefix
	else
		./configure --prefix=$arch_prefix --release
		cat $patchdir/mac_universal.pri >> conf.pri
		cat $patchdir/mac_universal.pri >> confapp.pri
		$QTDIR/bin/qmake
		make
		make install
	fi
}

build_package_qca_ossl() {
	tar jxvf $pkgdir/$qca_ossl_file
	cd qca-ossl-*
	if [ "$platform" == "win" ]; then
		if [ "$target_arch" == "x86_64" ]; then
			qtdir=$QTDIR64
		else
			qtdir=$QTDIR32
		fi
		mqtdir=`get_msys_path $qtdir`
		PATH=$mqtdir/bin:$PATH ./configure.exe --qtdir=$qtdir --release --with-qca=/mingw/msys/1.0$arch_prefix --with-openssl-inc=/mingw/msys/1.0$base_prefix/../openssl/$target_arch/include --with-openssl-lib=/mingw/msys/1.0$base_prefix/../openssl/$target_arch/lib
		mingw32-make
	else
		./configure --release --with-qca=$arch_prefix
		cat $patchdir/mac_universal.pri >> conf.pri
		$QTDIR/bin/qmake
		make
	fi

	mkdir -p $arch_prefix/plugins/crypto

	if [ "$platform" == "win" ]; then
		cp lib/*.dll $arch_prefix/plugins/crypto
	else
		cp lib/*.dylib $arch_prefix/plugins/crypto
	fi
}

build_package_qca_gnupg() {
	tar jxvf $pkgdir/$qca_gnupg_file
	cd qca-gnupg-*
	if [ "$platform" == "win" ]; then
		if [ "$target_arch" == "x86_64" ]; then
			qtdir=$QTDIR64
		else
			qtdir=$QTDIR32
		fi
		mqtdir=`get_msys_path $qtdir`
		sed -e "s/windows:CONFIG += crypto/#windows:CONFIG += crypto/g" qca-gnupg.pro > qca-gnupg.pro.tmp
		mv qca-gnupg.pro.tmp qca-gnupg.pro
		cat > conf_win.pri <<EOT
CONFIG -= debug release debug_and_release
CONFIG += release

QCA_INCDIR = c:/mingw/msys/1.0$base_prefix/../qca/$target_arch/include
QCA_LIBDIR = c:/mingw/msys/1.0$base_prefix/../qca/$target_arch/lib
EOT
		cat $patchdir/qcaconf >> conf_win.pri
		PATH=$mqtdir/bin:$PATH $mqtdir/bin/qmake
		mingw32-make
	else
		./configure --release --with-qca=$arch_prefix
		cat $patchdir/mac_universal.pri >> conf.pri
		$QTDIR/bin/qmake
		make
	fi

	mkdir -p $arch_prefix/plugins/crypto

	if [ "$platform" == "win" ]; then
		cp lib/*.dll $arch_prefix/plugins/crypto
	else
		cp lib/*.dylib $arch_prefix/plugins/crypto
	fi
}

if [ "$target_arch" != "" ]; then
	build_package $package_name $target_arch
else
	build_package $package_name uni
fi
