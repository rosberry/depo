prefix=/usr/local
bindir=$(prefix)/bin
binary=depo
release_binary=.build/release/Depo
executable_path=$(bindir)/$(binary)

SCRIPTS = build_swift_package.sh build_pod.sh merge_package.sh move_built_pod.sh

define SCRIPT_INSTALL
cp Shell/$(1) $(bindir)/$(1);
chmod +x $(bindir)/$(1);
endef

.PHONY: build install uninstall clean install_scripts

install: build install_scripts
	cp $(release_binary) $(executable_path)

build:
	swift build -c release --disable-sandbox

install_scripts:
	$(foreach script,$(SCRIPTS),$(call SCRIPT_INSTALL,$(script)))

uninstall:
	rm -rf $(bindir)/$(binary) $(executable_path)

xcode:
	swift package generate-xcodeproj

clean:
	rm -rf .build

test:

