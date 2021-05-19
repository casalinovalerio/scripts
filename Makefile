PKGNAME := 5amuscripts

PKGVER := $(shell git rev-parse --short HEAD)
PKGREL := $(shell date +%Y%m%d)

PREFIX ?= /usr

prepare: clean
	sed 's/PKGVER/$(PKGVER)/g;s/PKGREL/$(PKGREL)/g' PKGBUILD.template > PKGBUILD
	tar czf "${PKGNAME}-$(PKGVER).tar.gz" sh Makefile

install:
	mkdir -p $(PREFIX)/bin
	install -Dm755 sh/* $(PREFIX)/bin/

clean:
	rm -rf *tar.gz *.pkg.tar.zst pkg src PKGBUILD