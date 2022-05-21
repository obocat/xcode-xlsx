all:
	swift build -c release
install:
	cd .build/release && cp -f xcode-xlsx /usr/local/bin/xcode-xlsx
