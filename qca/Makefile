UNAME := $(shell uname)
PREFIX = /psidepsbase/qca
VERSION = 2.0.3

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
	rm -f qca-$(VERSION)-win.zip

dist: qca-$(VERSION)-win.zip

packages/$(qca_file):
	mkdir -p packages
	../fetch.sh $(qca_url) packages/$(qca_file)

packages/$(qca_ossl_file):
	mkdir -p packages
	../fetch.sh $(qca_ossl_url) packages/$(qca_ossl_file)

packages/$(qca_gnupg_file):
	mkdir -p packages
	../fetch.sh $(qca_gnupg_url) packages/$(qca_gnupg_file)

build/i386/qca/ok: packages/$(qca_file)
	mkdir -p build
	./build_package.sh qca i386 $(PREFIX) $(PWD)/install
	touch build/i386/qca/ok

build/x86_64/qca/ok: packages/$(qca_file)
	mkdir -p build
	./build_package.sh qca x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/qca/ok

build/i386/qca_ossl/ok: packages/$(qca_ossl_file)
	mkdir -p build
	./build_package.sh qca_ossl i386 $(PREFIX) $(PWD)/install
	touch build/i386/qca_ossl/ok

build/x86_64/qca_ossl/ok: packages/$(qca_ossl_file)
	mkdir -p build
	./build_package.sh qca_ossl x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/qca_ossl/ok

build/i386/qca_gnupg/ok: packages/$(qca_gnupg_file)
	mkdir -p build
	./build_package.sh qca_gnupg i386 $(PREFIX) $(PWD)/install
	touch build/i386/qca_gnupg/ok

build/x86_64/qca_gnupg/ok: packages/$(qca_gnupg_file)
	mkdir -p build
	./build_package.sh qca_gnupg x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/qca_gnupg/ok

dist/qca-$(VERSION)-win: build/i386/qca/ok build/x86_64/qca/ok build/i386/qca_ossl/ok build/x86_64/qca_ossl/ok build/i386/qca_gnupg/ok build/x86_64/qca_gnupg/ok
	./prep_dist.sh $(PWD)/install $(PREFIX) dist/qca-$(VERSION)-win

qca-$(VERSION)-win.zip: dist/qca-$(VERSION)-win
	rm -f qca-$(VERSION)-win.zip
	cd dist && zip -r ../qca-$(VERSION)-win.zip qca-$(VERSION)-win
