#!/bin/bash
set -e

if [ $# != 3 ]; then
	echo "usage: $0 [destdir] [prefix] [distdir]"
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

#destdir=$1
destdir=
base_prefix=$2
dist_base=$3

# args: file, lib prefix
# note: this method uses bash-isms
cleanlibpaths() {
	plen=${#2}
	otlist=`otool -L $1 | tail -n+2 | cut -f 2 | cut -f 1 -d " "`
	for otlib in $otlist; do
		case $otlib in
			${2}*) dofix=yes;;
			*) dofix=no;;
		esac
		if [ "$dofix" == "yes" ]; then
			rlen=`expr ${#otlib} - $plen`
			relpath=${otlib:$plen:$rlen}
			install_name_tool -change $otlib $relpath $1
		fi
	done
}

mkdir -p $dist_base

TARGET_ARCHES="i386 x86_64"

if [ "$platform" == "mac" ]; then
	for target_arch in $TARGET_ARCHES; do
		target_base=$destdir$base_prefix/$target_arch
		target_dist_base=$dist_base/$target_arch

		mkdir -p $target_dist_base

		QT_FRAMEWORKS="QtCore QtNetwork QtGui"

		cp -a $target_base/demo $target_dist_base
		cp -a $target_base/plugins $target_dist_base

		for g in $QT_FRAMEWORKS; do
			install_name_tool -change $QTDIR/lib/$g.framework/Versions/4/$g $g.framework/Versions/4/$g $target_dist_base/demo/demo
			install_name_tool -change $QTDIR/lib/$g.framework/Versions/4/$g $g.framework/Versions/4/$g $target_dist_base/plugins/libgstprovider.dylib
		done

		cleanlibpaths $target_dist_base/plugins/libgstprovider.dylib /psidepsbase/gstbundle/$target_arch/lib/ # note: trailing slash important
	done

	mkdir -p $dist_base
	mkdir -p $dist_base/uni/demo
	mkdir -p $dist_base/uni/plugins

	PARTS=
	for target_arch in $TARGET_ARCHES; do
		PARTS="$PARTS $dist_base/$target_arch/demo/demo"
	done
	lipo -output $dist_base/uni/demo/demo -create $PARTS

	PARTS=
	for target_arch in $TARGET_ARCHES; do
		PARTS="$PARTS $dist_base/$target_arch/plugins/libgstprovider.dylib"
	done
	lipo -output $dist_base/uni/plugins/libgstprovider.dylib -create $PARTS

	for target_arch in $TARGET_ARCHES; do
		rm -rf $dist_base/$target_arch
	done
	mv $dist_base/uni/demo $dist_base/uni/plugins $dist_base
	rmdir $dist_base/uni
else
	for target_arch in $TARGET_ARCHES; do
		target_base=$destdir$base_prefix/$target_arch
		target_dist_base=$dist_base/$target_arch

		mkdir -p $target_dist_base
		cp -a $target_base/demo $target_dist_base
		cp -a $target_base/plugins $target_dist_base
	done

	cp -a distfiles/win/README $dist_base
fi
