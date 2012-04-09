UNAME := $(shell uname)
PREFIX = /psidepsbase/zlib

include package_info

ifeq ($(UNAME), MINGW32_NT-6.1)
VERSION = 1.2.6-win
all: default-mingw
else
all: default-unknown
endif

default-mingw: dist

clean:
	rm -rf build $(PREFIX) dist

dist: zlib-$(VERSION).zip

packages/$(zlib_file):
	mkdir -p packages
	../fetch.sh $(zlib_url) packages/$(zlib_file)

build/i386/zlib/ok: packages/$(zlib_file)
	mkdir -p build
	./build_package.sh zlib i386 $(PREFIX) $(PWD)/install
	touch build/i386/zlib/ok

dist/zlib-$(VERSION): build/i386/zlib/ok
	./prep_dist.sh $(PWD)/install $(PREFIX) dist/zlib-$(VERSION)

zlib-$(VERSION).zip: dist/zlib-$(VERSION)
	cd dist && zip -r ../zlib-$(VERSION).zip zlib-$(VERSION)
