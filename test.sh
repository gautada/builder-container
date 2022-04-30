test() {
 git clone https://github.com/gautada/alpine-container.git
 cd alpine-container
 podman build --build-arg ALPINE_VERSION=3.15.4 --file Containerfile --label revision="$(git rev-parse HEAD)" version="$(date +%Y.%m.%d)" --no-cache --tag alpine:dev .
}
