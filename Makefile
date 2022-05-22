all:
	swift build -c release
install:
	cp -f .build/release/xcode-xlsx /usr/local/bin/xcode-xlsx
