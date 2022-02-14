prefix=/usr/local
bindir=$(prefix)/bin
binary=depo
release_binary=.build/release/Depo
executable_path=$(bindir)/$(binary)
completion_script=/usr/share/zsh/site-functions/_depo

SOURCES := $(shell find Sources -name "*.swift")

.PHONY: build install uninstall clean completion test install

install: $(executable_path)

build: $(binary)

$(executable_path): $(release_binary)
	cp $(release_binary) $(executable_path)

$(binary): $(release_binary)
	cp $(release_binary) $(binary)

$(release_binary): $(SOURCES)
	swift build -c release --disable-sandbox

completion: $(completion_script)

$(completion_script): $(executable_path)
	$(executable_path) --generate-completion-script zsh > $(completion_script)

uninstall:
	rm -rf $(bindir)/$(binary) $(executable_path)

xcode:
	swift package generate-xcodeproj

test:
	xcodebuild test -scheme Depo-Package

clean:
	rm -rf .build

