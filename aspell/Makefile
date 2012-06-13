UNAME := $(shell uname)
PREFIX = /psidepsbase/aspell
VERSION = 0.60.6.1

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
	rm -f aspell-$(VERSION)-win.zip

dist: aspell-$(VERSION)-win.zip

packages/$(aspell_file):
	mkdir -p packages
	../fetch.sh $(aspell_url) packages/$(aspell_file)

packages/$(aspell_en_file):
	mkdir -p packages
	../fetch.sh $(aspell_en_url) packages/$(aspell_en_file)

build/i386/aspell/ok: packages/$(aspell_file)
	mkdir -p build
	./build_package.sh aspell i386 $(PREFIX) $(PWD)/install
	touch build/i386/aspell/ok

build/x86_64/aspell/ok: packages/$(aspell_file)
	mkdir -p build
	./build_package.sh aspell x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/aspell/ok

build/i386/aspell_en/ok: packages/$(aspell_en_file)
	mkdir -p build
	./build_package.sh aspell_en i386 $(PREFIX) $(PWD)/install
	touch build/i386/aspell_en/ok

build/x86_64/aspell_en/ok: packages/$(aspell_en_file)
	mkdir -p build
	./build_package.sh aspell_en x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/aspell_en/ok

dist/aspell-$(VERSION)-win: build/i386/aspell/ok build/x86_64/aspell/ok build/i386/aspell_en/ok build/x86_64/aspell_en/ok
	./prep_dist.sh $(PWD)/install $(PREFIX) dist/aspell-$(VERSION)-win

aspell-$(VERSION)-win.zip: dist/aspell-$(VERSION)-win
	rm -f aspell-$(VERSION)-win.zip
	cd dist && zip -r ../aspell-$(VERSION)-win.zip aspell-$(VERSION)-win
