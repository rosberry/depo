prefix=/usr/local
bindir=$(prefix)/bin
binary=carpod
release_binary=.build/release/CarPod
executable_path=$(bindir)/$(binary)
build_pod_path=Shell/build_pod.sh
merge_pod_path=Shell/merge_pod.sh

build:
	swift build -c release --disable-sandbox

install_build_pod:
	cp $(build_pod_path) $(bindir)/build_pod.sh
	chmod +x $(bindir)/build_pod.sh

install_merge_pod:
	cp $(merge_pod_path) $(bindir)/merge_pod.sh
	chmod +x $(bindir)/merge_pod.sh

install: build install_build_pod install_merge_pod
	cp $(release_binary) $(executable_path)

uninstall:
	rm -rf $(bindir)/$(binary) $(executable_path)

clean:
	rm -rf .build

.PHONY: build install uninstall clean
