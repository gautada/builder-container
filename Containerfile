ARG ALPINE_TAG=3.15.4
FROM gautada/alpine:3.15.4

LABEL version="2022-04-29"
LABEL source="https://github.com/gautada/podman-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="This container is a a podman installation for building OCI containers."

RUN apk add --no-cache git iputils openssh fuse-overlayfs shadow slirp4netns sudo

ARG PODMAN_VERSION=3.4.7-r0
RUN apk add --no-cache podman="$PODMAN_VERSION"

ARG USER=podman
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "$USER:$USER" | chpasswd \
 && echo "%wheel         ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && usermod -aG wheel $USER

USER $USER
WORKDIR /home/$USER

# RUN podman system connection add x86 --identity /home/bob/.ssh/podman_key ssh://podman@podman-x86.cicd.svc.cluster.local:22/tmp/podman-run-1000/podman/podman.sock \
# RUN podman system connection add arm --identity /home/$USER/.ssh/podman_key ssh://podman@podman-arm.cicd.svc.cluster.local:22/tmp/podman-run-1000/podman/podman.sock
  
COPY builder-base /builder-base
COPY version.sh /etc/profile.d/version.sh
COPY test.sh /etc/profile.d/test.sh


