UNAME := $(shell uname)
PREFIX = /psidepsbase/gstbundle

include package_info

ifeq ($(UNAME), Darwin)
VERSION = 0.10.36-mac
all: default-mac
else ifeq ($(UNAME), MINGW32_NT-6.1)
VERSION = 0.10.36-win
all: default-mingw
else
all: default-unknown
endif

default-mac: dist

clean:
	rm -rf build $(PREFIX) dist

dist: gstbundle-$(VERSION).tar.bz2

packages/$(gettext_file):
	mkdir -p packages
	../fetch.sh $(gettext_url) packages/$(gettext_file)

packages/$(glib_file):
	mkdir -p packages
	../fetch.sh $(glib_url) packages/$(glib_file)

packages/$(pkgconfig_file):
	mkdir -p packages
	../fetch.sh $(pkgconfig_url) packages/$(pkgconfig_file)

packages/$(libjpeg_file):
	mkdir -p packages
	../fetch.sh $(libjpeg_url) packages/$(libjpeg_file)

packages/$(libogg_file):
	mkdir -p packages
	../fetch.sh $(libogg_url) packages/$(libogg_file)

packages/$(libvorbis_file):
	mkdir -p packages
	../fetch.sh $(libvorbis_url) packages/$(libvorbis_file)

packages/$(libtheora_file):
	mkdir -p packages
	../fetch.sh $(libtheora_url) packages/$(libtheora_file)

packages/$(libspeex_file):
	mkdir -p packages
	../fetch.sh $(libspeex_url) packages/$(libspeex_file)

packages/$(gstreamer_file):
	mkdir -p packages
	../fetch.sh $(gstreamer_url) packages/$(gstreamer_file)

packages/$(gstbase_file):
	mkdir -p packages
	../fetch.sh $(gstbase_url) packages/$(gstbase_file)

packages/$(gstgood_file):
	mkdir -p packages
	../fetch.sh $(gstgood_url) packages/$(gstgood_file)

build/i386/gettext/ok: packages/$(gettext_file)
	mkdir -p build
	./build_package.sh gettext i386 $(PREFIX) $(PWD)/install
	touch build/i386/gettext/ok

build/x86_64/gettext/ok: packages/$(gettext_file)
	mkdir -p build
	./build_package.sh gettext x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/gettext/ok

build/i386/glib/ok: packages/$(glib_file)
	mkdir -p build
	./build_package.sh glib i386 $(PREFIX) $(PWD)/install
	touch build/i386/glib/ok

build/x86_64/glib/ok: packages/$(glib_file)
	mkdir -p build
	./build_package.sh glib x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/glib/ok

build/i386/pkgconfig/ok: packages/$(pkgconfig_file)
	mkdir -p build
	./build_package.sh pkgconfig i386 $(PREFIX) $(PWD)/install
	touch build/i386/pkgconfig/ok

build/x86_64/pkgconfig/ok: packages/$(pkgconfig_file)
	mkdir -p build
	./build_package.sh pkgconfig x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/pkgconfig/ok

build/i386/libjpeg/ok: packages/$(libjpeg_file)
	mkdir -p build
	./build_package.sh libjpeg i386 $(PREFIX) $(PWD)/install
	touch build/i386/libjpeg/ok

build/x86_64/libjpeg/ok: packages/$(libjpeg_file)
	mkdir -p build
	./build_package.sh libjpeg x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/libjpeg/ok

build/i386/libogg/ok: packages/$(libogg_file)
	mkdir -p build
	./build_package.sh libogg i386 $(PREFIX) $(PWD)/install
	touch build/i386/libogg/ok

build/x86_64/libogg/ok: packages/$(libogg_file)
	mkdir -p build
	./build_package.sh libogg x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/libogg/ok

build/i386/libvorbis/ok: packages/$(libvorbis_file)
	mkdir -p build
	./build_package.sh libvorbis i386 $(PREFIX) $(PWD)/install
	touch build/i386/libvorbis/ok

build/x86_64/libvorbis/ok: packages/$(libvorbis_file)
	mkdir -p build
	./build_package.sh libvorbis x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/libvorbis/ok

build/i386/libtheora/ok: packages/$(libtheora_file)
	mkdir -p build
	./build_package.sh libtheora i386 $(PREFIX) $(PWD)/install
	touch build/i386/libtheora/ok

build/x86_64/libtheora/ok: packages/$(libtheora_file)
	mkdir -p build
	./build_package.sh libtheora x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/libtheora/ok

build/i386/libspeex/ok: packages/$(libspeex_file)
	mkdir -p build
	./build_package.sh libspeex i386 $(PREFIX) $(PWD)/install
	touch build/i386/libspeex/ok

build/x86_64/libspeex/ok: packages/$(libspeex_file)
	mkdir -p build
	./build_package.sh libspeex x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/libspeex/ok

build/i386/gstreamer/ok: packages/$(gstreamer_file)
	mkdir -p build
	./build_package.sh gstreamer i386 $(PREFIX) $(PWD)/install
	touch build/i386/gstreamer/ok

build/x86_64/gstreamer/ok: packages/$(gstreamer_file)
	mkdir -p build
	./build_package.sh gstreamer x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/gstreamer/ok

build/i386/gstbase/ok: packages/$(gstbase_file)
	mkdir -p build
	./build_package.sh gstbase i386 $(PREFIX) $(PWD)/install
	touch build/i386/gstbase/ok

build/x86_64/gstbase/ok: packages/$(gstbase_file)
	mkdir -p build
	./build_package.sh gstbase x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/gstbase/ok

build/i386/gstgood/ok: packages/$(gstgood_file)
	mkdir -p build
	./build_package.sh gstgood i386 $(PREFIX) $(PWD)/install
	touch build/i386/gstgood/ok

build/x86_64/gstgood/ok: packages/$(gstgood_file)
	mkdir -p build
	./build_package.sh gstgood x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/gstgood/ok

dist/gstbundle-$(VERSION): build/i386/gettext/ok build/x86_64/gettext/ok build/i386/glib/ok build/x86_64/glib/ok build/i386/pkgconfig/ok build/x86_64/pkgconfig/ok build/i386/libjpeg/ok build/x86_64/libjpeg/ok build/i386/libogg/ok build/x86_64/libogg/ok build/i386/libvorbis/ok build/x86_64/libvorbis/ok build/i386/libtheora/ok build/x86_64/libtheora/ok build/i386/libspeex/ok build/x86_64/libspeex/ok build/i386/gstreamer/ok build/x86_64/gstreamer/ok build/i386/gstbase/ok build/x86_64/gstbase/ok build/i386/gstgood/ok build/x86_64/gstgood/ok
	./prep_dist.sh $(PWD)/install $(PREFIX) dist/gstbundle-$(VERSION)

gstbundle-$(VERSION).tar.bz2: dist/gstbundle-$(VERSION)
	cd dist && tar jcvf ../gstbundle-$(VERSION).tar.bz2 gstbundle-$(VERSION)
