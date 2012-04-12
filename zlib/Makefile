UNAME := $(shell uname)
PREFIX = /psidepsbase/zlib
VERSION = 1.2.6

include package_info

ifeq ($(UNAME), MINGW32_NT-6.1)
PLATFORM = win
all: default-mingw
else
all: default-unknown
endif

default-mingw: dist

clean:
	rm -rf build $(PREFIX) dist

distclean: clean
	rm -rf packages
	rm -f zlib-$(VERSION)-win.zip

dist: zlib-$(VERSION)-win.zip

packages/$(zlib_file):
	mkdir -p packages
	../fetch.sh $(zlib_url) packages/$(zlib_file)

build/i386/zlib/ok: packages/$(zlib_file)
	mkdir -p build
	./build_package.sh zlib i386 $(PREFIX) $(PWD)/install
	touch build/i386/zlib/ok

build/x86_64/zlib/ok: packages/$(zlib_file)
	mkdir -p build
	./build_package.sh zlib x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/zlib/ok

dist/zlib-$(VERSION)-win: build/i386/zlib/ok build/x86_64/zlib/ok
	./prep_dist.sh $(PWD)/install $(PREFIX) dist/zlib-$(VERSION)-win

zlib-$(VERSION)-win.zip: dist/zlib-$(VERSION)-win
	rm -f zlib-$(VERSION)-win.zip
	cd dist && zip -r ../zlib-$(VERSION)-win.zip zlib-$(VERSION)-win
