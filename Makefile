prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	install -d "$(bindir)"
	install ".build/release/xcode-xlsx" "$(bindir)/xcode-xlsx"

uninstall:
	rm -rf "$(bindir)/xcode-xlsx"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
