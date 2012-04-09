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

TARGET_ARCHES="i386 x86_64"

for target_arch in $TARGET_ARCHES; do
	target_base=$destdir$base_prefix/$target_arch
	target_dist_base=$dist_base/$target_arch

	BIN_FILES=
	BINEXE_FILES=
	for n in `find $target_base/bin -maxdepth 1 -type f`; do
		base_n=`basename $n`
		BIN_FILES="$BIN_FILES $base_n"
		if file $n | grep "Mach-O" >/dev/null; then
			BINEXE_FILES="$BINEXE_FILES $base_n"
		fi
	done

	LIB_FILES=
	for n in `find $target_base/lib -maxdepth 1 -type f -name \*.dylib`; do
		base_n=`basename $n`
		LIB_FILES="$LIB_FILES $base_n"
	done

	LIB_SUBS=
	for n in `find $target_base/lib -maxdepth 1 -name \*.dylib`; do
		base_n=`basename $n`
		LIB_SUBS="$LIB_SUBS $base_n"
	done

	LIB_GST_FILES=
	for n in `find $target_base/lib/gstreamer-0.10 -maxdepth 1 -type f -name \*.so`; do
		base_n=`basename $n`
		LIB_GST_FILES="$LIB_GST_FILES $base_n"
	done

	LIBEXE_GST_FILES="gst-plugin-scanner"

	mkdir -p $target_dist_base
	cp -a $target_base/bin $target_dist_base
	cp -a $target_base/include $target_dist_base
	cp -a $target_base/lib $target_dist_base
	cp -a $target_base/libexec $target_dist_base

	for n in $BINEXE_FILES; do
		for i in $LIB_SUBS; do
			install_name_tool -change $base_prefix/$target_arch/lib/$i $i $target_dist_base/bin/$n
		done
	done

	for n in $LIB_FILES; do
		install_name_tool -id $n $target_dist_base/lib/$n
		for i in $LIB_SUBS; do
			install_name_tool -change $base_prefix/$target_arch/lib/$i $i $target_dist_base/lib/$n
		done
	done

	for n in $LIB_GST_FILES; do
		install_name_tool -id $n $target_dist_base/lib/gstreamer-0.10/$n
		for i in $LIB_SUBS; do
			install_name_tool -change $base_prefix/$target_arch/lib/$i $i $target_dist_base/lib/gstreamer-0.10/$n
		done
	done

	for n in $LIBEXE_GST_FILES; do
		for i in $LIB_SUBS; do
			install_name_tool -change $base_prefix/$target_arch/lib/$i $i $target_dist_base/libexec/gstreamer-0.10/$n
		done
	done
done

BIN_FILES="gst-inspect-0.10 gst-launch-0.10"

LIB_FILES=
for n in `find $destdir$base_prefix/i386/lib -maxdepth 1 -type f -name \*.dylib`; do
	base_n=`basename $n`
	if [ ! -f "$destdir$base_prefix/x86_64/lib/$base_n" ]; then
		continue
	fi
	LIB_FILES="$LIB_FILES $base_n"
done

LIB_LINKS=
for n in `find $destdir$base_prefix/i386/lib -maxdepth 1 -type l -name \*.dylib`; do
	base_n=`basename $n`
	if [ ! -f "$destdir$base_prefix/x86_64/lib/$base_n" ]; then
		continue
	fi
	LIB_LINKS="$LIB_LINKS $base_n"
done

LIB_GST_FILES=
for n in `find $destdir$base_prefix/i386/lib/gstreamer-0.10 -maxdepth 1 -type f -name \*.so`; do
	base_n=`basename $n`
	if [ ! -f "$destdir$base_prefix/x86_64/lib/gstreamer-0.10/$base_n" ]; then
		continue
	fi
	LIB_GST_FILES="$LIB_GST_FILES $base_n"
done

LIBEXE_GST_FILES="gst-plugin-scanner"

mkdir -p $dist_base
mkdir -p $dist_base/uni/bin
mkdir -p $dist_base/uni/lib
mkdir -p $dist_base/uni/lib/gstreamer-0.10
mkdir -p $dist_base/uni/libexec/gstreamer-0.10

for n in $BIN_FILES; do
	PARTS=
	for target_arch in $TARGET_ARCHES; do
		PARTS="$PARTS $dist_base/$target_arch/bin/$n"
	done
	lipo -output $dist_base/uni/bin/$n -create $PARTS
done

for n in $LIB_FILES; do
	PARTS=
	for target_arch in $TARGET_ARCHES; do
		PARTS="$PARTS $dist_base/$target_arch/lib/$n"
	done
	lipo -output $dist_base/uni/lib/$n -create $PARTS
done

for n in $LIB_LINKS; do
	cp -a $dist_base/i386/lib/$n $dist_base/uni/lib/$n
done

for n in $LIB_GST_FILES; do
	PARTS=
	for target_arch in $TARGET_ARCHES; do
		PARTS="$PARTS $dist_base/$target_arch/lib/gstreamer-0.10/$n"
	done
	lipo -output $dist_base/uni/lib/gstreamer-0.10/$n -create $PARTS
done

for n in $LIBEXE_GST_FILES; do
	PARTS=
	for target_arch in $TARGET_ARCHES; do
		PARTS="$PARTS $dist_base/$target_arch/libexec/gstreamer-0.10/$n"
	done
	lipo -output $dist_base/uni/libexec/gstreamer-0.10/$n -create $PARTS
done

cp -a distfiles/mac/README $dist_base
