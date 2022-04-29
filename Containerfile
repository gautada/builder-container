ARG ALPINE_TAG=3.15.4
FROM alpine:$ALPINE_TAG as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:$ALPINE_TAG

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

RUN apk add --no-cache git iputils openssh fuse-overlayfs shadow slirp4netns sudo

ARG PODMAN_VERSION=3.4.7-r0
RUN apk add --no-cache buildah podman=$PODMAN_VERSION

ARG USER=podman
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "$USER:$USER" | chpasswd \
 && echo "%wheel         ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && usermod -aG wheel $USER

USER $USER
WORKDIR /home/$USER

# RUN podman system connection add x86 --identity /home/bob/.ssh/podman_key ssh://podman@podman-x86.cicd.svc.cluster.local:22/tmp/podman-run-1000/podman/podman.sock \
RUN podman system connection add arm --identity /home/$USER/.ssh/podman_key ssh://podman@podman-arm.cicd.svc.cluster.local:22/tmp/podman-run-1000/podman/podman.sock
  
COPY builder-base /builder-base


