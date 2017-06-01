#!/bin/sh
set -e

if [ $# != 3 ]; then
	echo "usage: $0 [destdir] [prefix] [distdir]"
	exit 1
fi

../detect_platform.sh

#destdir=$1
destdir=
base_prefix=$2
dist_base=$3

mkdir -p $dist_base

if [ "$platform" == "mac" ]; then
	target_base=$destdir$base_prefix
	target_dist_base=$dist_base

	mkdir -p $target_dist_base
	cp -a $target_base/bin $target_dist_base
	cp -a $target_base/lib $target_dist_base
	cp -a $target_base/plugins $target_dist_base

	cp -a distfiles/mac/README $dist_base

	QT_FRAMEWORKS="QtCore"

	install_name_tool -id qca.framework/Versions/2/qca $target_dist_base/lib/qca.framework/qca

	for g in $QT_FRAMEWORKS; do
		install_name_tool -change $QTDIR/lib/$g.framework/Versions/4/$g $g.framework/Versions/4/$g $target_dist_base/lib/qca.framework/qca
        done

	install_name_tool -change $target_base/lib/qca.framework/Versions/2/qca qca.framework/Versions/2/qca $target_dist_base/bin/qcatool2
	for g in $QT_FRAMEWORKS; do
		install_name_tool -change $QTDIR/lib/$g.framework/Versions/4/$g $g.framework/Versions/4/$g $target_dist_base/bin/qcatool2
	done

	for p in `find $target_dist_base/plugins/crypto -name \*.dylib`; do
		base_p=`basename $p`
		install_name_tool -change $target_base/lib/qca.framework/Versions/2/qca qca.framework/Versions/2/qca $target_dist_base/plugins/crypto/$base_p
		for g in $QT_FRAMEWORKS; do
			install_name_tool -change $QTDIR/lib/$g.framework/Versions/4/$g $g.framework/Versions/4/$g $target_dist_base/plugins/crypto/$base_p
		done
	done
else
	TARGET_ARCHES="i386 x86_64"

	for target_arch in $TARGET_ARCHES; do
		target_base=$destdir$base_prefix/$target_arch
		target_dist_base=$dist_base/$target_arch

		mkdir -p $target_dist_base
		cp -a $target_base/bin $target_dist_base
		cp -a $target_base/include $target_dist_base
		cp -a $target_base/lib $target_dist_base
		cp -a $target_base/plugins $target_dist_base
	done

	cp -a distfiles/win/README $dist_base
fi
