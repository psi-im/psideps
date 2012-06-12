UNAME := $(shell uname)
PREFIX = /psidepsbase/openssl
VERSION = 1.0.1c

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
	rm -f openssl-$(VERSION)-win.zip

dist: openssl-$(VERSION)-win.zip

packages/$(openssl_file):
	mkdir -p packages
	../fetch.sh $(openssl_url) packages/$(openssl_file)

build/i386/openssl/ok: packages/$(openssl_file)
	mkdir -p build
	./build_package.sh openssl i386 $(PREFIX) $(PWD)/install
	touch build/i386/openssl/ok

build/x86_64/openssl/ok: packages/$(openssl_file)
	mkdir -p build
	./build_package.sh openssl x86_64 $(PREFIX) $(PWD)/install
	touch build/x86_64/openssl/ok

dist/openssl-$(VERSION)-win: build/i386/openssl/ok build/x86_64/openssl/ok
	./prep_dist.sh $(PWD)/install $(PREFIX) dist/openssl-$(VERSION)-win

openssl-$(VERSION)-win.zip: dist/openssl-$(VERSION)-win
	rm -f openssl-$(VERSION)-win.zip
	cd dist && zip -r ../openssl-$(VERSION)-win.zip openssl-$(VERSION)-win
