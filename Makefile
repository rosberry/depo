prefix=/usr/local
bindir=$(prefix)/bin
binary=carpod
release_binary=.build/release/CarPod
executable_path=$(bindir)/$(binary)
build_pod_path=build_pod.sh

build:
	swift build -c release --disable-sandbox

install_build_pod:
	cp $(build_pod_path) $(bindir)/build_pod.sh

install: build install_build_pod
	cp $(release_binary) $(executable_path)

uninstall:
	rm -rf $(bindir)/$(binary) $(executable_path)

clean:
	rm -rf .build

.PHONY: build install uninstall clean
