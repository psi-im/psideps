include ../detect_platform.mk
PREFIX = /psidepsbase/psimedia
VERSION = 1.0.5

include package_info

all: $(DEFAULT_TARGET)

default-mac: dist-mac

default-win: dist-win

clean:
	rm -rf build $(PREFIX) dist

distclean: clean
	rm -rf packages
ifeq ($(PLATFORM), mac)
	rm -f psimedia-$(VERSION)-mac.tar.bz2
else
	rm -f psimedia-$(VERSION)-win.zip
endif

dist-mac: psimedia-$(VERSION)-mac.tar.bz2

dist-mingw : psimedia-$(VERSION)-win.zip

packages/$(psimedia_file):
	mkdir -p packages
	../fetch.sh $(psimedia_url) packages/$(psimedia_file)

build/i386/psimedia/ok: packages/$(psimedia_file)
	mkdir -p build
	./build_package.sh psimedia i386 $(PREFIX) $(PWD)/install
	touch build/i386/psimedia/ok

build/x86_64/psimedia/ok: packages/$(psimedia_file)
	mkdir -p build
	./build_package.sh psimedia x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/psimedia/ok

dist/psimedia-$(VERSION)-mac: build/i386/psimedia/ok build/x86_64/psimedia/ok
	./prep_dist.sh $(PWD)/install $(PREFIX) dist/psimedia-$(VERSION)-mac

dist/psimedia-$(VERSION)-win: build/i386/psimedia/ok build/x86_64/psimedia/ok
	./prep_dist.sh $(PWD)/install $(PREFIX) dist/psimedia-$(VERSION)-win

psimedia-$(VERSION)-mac.tar.bz2: dist/psimedia-$(VERSION)-mac
	cd dist && tar jcvf ../psimedia-$(VERSION)-mac.tar.bz2 psimedia-$(VERSION)-mac

psimedia-$(VERSION)-win.zip: dist/psimedia-$(VERSION)-win
	rm -f psimedia-$(VERSION)-win.zip
	cd dist && zip -r ../psimedia-$(VERSION)-win.zip psimedia-$(VERSION)-win
