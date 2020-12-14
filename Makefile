prefix=/usr/local
bindir=$(prefix)/bin
binary=depo
release_binary=.build/release/Depo
executable_path=$(bindir)/$(binary)
completion_script=/usr/share/zsh/site-functions/_depo

SCRIPTS = build_swift_package.sh merge_package.sh move_built_pod.sh
SOURCES := $(shell find Sources -name "*.swift")

define SCRIPT_INSTALL
cp Shell/$(1) $(bindir)/$(1);
chmod +x $(bindir)/$(1);
endef

.PHONY: build install uninstall clean install_scripts completion test install

install: $(executable_path)

$(executable_path): $(release_binary)
	cp $(release_binary) $(executable_path)

$(binary): $(release_binary)
	cp $(release_binary) $(binary)

$(release_binary): $(SOURCES)
	swift build -c release --disable-sandbox

completion: $(completion_script)

$(completion_script): $(executable_path)
	$(executable_path) --generate-completion-script zsh > $(completion_script)

install_scripts:
	$(foreach script,$(SCRIPTS),$(call SCRIPT_INSTALL,$(script)))

uninstall:
	rm -rf $(bindir)/$(binary) $(executable_path)

xcode:
	swift package generate-xcodeproj

test:
	xcodebuild test -scheme Depo-Package

clean:
	rm -rf .build

