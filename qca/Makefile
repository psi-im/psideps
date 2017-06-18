UNAME := $(shell uname)
PREFIX = /psidepsbase/qca
VERSION = 2.1.3

include package_info

ifeq ($(UNAME), Darwin)
PLATFORM = mac
all: default-mac
else ifeq ($(UNAME), MINGW32_NT-6.1)
PLATFORM = win
all: default-mingw
else
all: default-unknown
endif

default-mac: dist-mac

default-mingw: dist-mingw

clean:
	rm -rf build $(PREFIX) dist

distclean: clean
	rm -rf packages
ifeq ($(PLATFORM), mac)
	rm -f qca-$(VERSION)-mac.tar.bz2
else
	rm -f qca-$(VERSION)-win.zip
endif

dist-mac: qca-$(VERSION)-mac.tar.bz2

dist-mingw : qca-$(VERSION)-win.zip

packages/$(qca_file):
	mkdir -p packages
	../fetch.sh $(qca_url) packages/$(qca_file)

packages/$(qca_ossl_file):
	mkdir -p packages
	../fetch.sh $(qca_ossl_url) packages/$(qca_ossl_file)

packages/$(qca_gnupg_file):
	mkdir -p packages
	../fetch.sh $(qca_gnupg_url) packages/$(qca_gnupg_file)

packages/$(qca_wingss_file):
	mkdir -p packages
	../fetch.sh $(qca_wingss_url) packages/$(qca_wingss_file)

build/i386/qca/ok: packages/$(qca_file)
	mkdir -p build
	./build_package.sh qca i386 $(PREFIX) $(PWD)/install
	touch build/i386/qca/ok

build/x86_64/qca/ok: packages/$(qca_file)
	mkdir -p build
	./build_package.sh qca x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/qca/ok

build/uni/qca/ok: packages/$(qca_file)
	mkdir -p build
	./build_package.sh qca "" $(PREFIX) $(PWD)/install
	touch build/uni/qca/ok

build/i386/qca_ossl/ok: packages/$(qca_ossl_file)
	mkdir -p build
	./build_package.sh qca_ossl i386 $(PREFIX) $(PWD)/install
	touch build/i386/qca_ossl/ok

build/x86_64/qca_ossl/ok: packages/$(qca_ossl_file)
	mkdir -p build
	./build_package.sh qca_ossl x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/qca_ossl/ok

build/uni/qca_ossl/ok: packages/$(qca_ossl_file)
	mkdir -p build
	./build_package.sh qca_ossl "" $(PREFIX) $(PWD)/install
	touch build/uni/qca_ossl/ok

build/i386/qca_gnupg/ok: packages/$(qca_gnupg_file)
	mkdir -p build
	./build_package.sh qca_gnupg i386 $(PREFIX) $(PWD)/install
	touch build/i386/qca_gnupg/ok

build/x86_64/qca_gnupg/ok: packages/$(qca_gnupg_file)
	mkdir -p build
	./build_package.sh qca_gnupg x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/qca_gnupg/ok

build/uni/qca_gnupg/ok: packages/$(qca_gnupg_file)
	mkdir -p build
	./build_package.sh qca_gnupg "" $(PREFIX) $(PWD)/install
	touch build/uni/qca_gnupg/ok

build/i386/qca_wingss/ok: packages/$(qca_wingss_file)
	mkdir -p build
	./build_package.sh qca_wingss i386 $(PREFIX) $(PWD)/install
	touch build/i386/qca_wingss/ok

build/x86_64/qca_wingss/ok: packages/$(qca_wingss_file)
	mkdir -p build
	./build_package.sh qca_wingss x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/qca_wingss/ok

dist/qca-$(VERSION)-mac: build/uni/qca/ok build/uni/qca_ossl/ok build/uni/qca_gnupg/ok
	./prep_dist.sh $(PWD)/install $(PREFIX) dist/qca-$(VERSION)-mac

dist/qca-$(VERSION)-win: build/i386/qca/ok build/x86_64/qca/ok build/i386/qca_ossl/ok build/x86_64/qca_ossl/ok build/i386/qca_gnupg/ok build/x86_64/qca_gnupg/ok build/i386/qca_wingss/ok build/x86_64/qca_wingss/ok
	./prep_dist.sh $(PWD)/install $(PREFIX) dist/qca-$(VERSION)-win

qca-$(VERSION)-mac.tar.bz2: dist/qca-$(VERSION)-mac
	cd dist && tar jcvf ../qca-$(VERSION)-mac.tar.bz2 qca-$(VERSION)-mac

qca-$(VERSION)-win.zip: dist/qca-$(VERSION)-win
	rm -f qca-$(VERSION)-win.zip
	cd dist && zip -r ../qca-$(VERSION)-win.zip qca-$(VERSION)-win
