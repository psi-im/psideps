#!/bin/sh
set -e

if [ $# != 3 ]; then
	echo "usage: $0 [destdir] [prefix] [distdir]"
	exit 1
fi

#destdir=$1
destdir=
base_prefix=$2
dist_base=$3

mkdir -p $dist_base

TARGET_ARCHES="i386"

for target_arch in $TARGET_ARCHES; do
	target_base=$destdir$base_prefix/$target_arch
	target_dist_base=$dist_base/$target_arch

	mkdir -p $target_dist_base
	cp -a $target_base/bin $target_dist_base
	cp -a $target_base/include $target_dist_base
	cp -a $target_base/lib $target_dist_base
done

cp -a distfiles/win/README $dist_base
