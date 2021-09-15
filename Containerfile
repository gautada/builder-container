ARG ALPINE_TAG=3.14.1
FROM alpine:$ALPINE_TAG as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

# This was the podman build pulled from the APK repository
# This worked for the most part but there was a WARN about
# '/' mounting that was never resolved
#
# FROM alpine:$ALPINE_TAG as config-podman
#
# RUN apk add --no-cache build-base  git
# RUN apk add --no-cache cni-plugins crun iptables ip6tables slirp4netns shadow-uidmap fuse-overlayfs  containers-common
# RUN apk add --no-cache go gpgme-dev libseccomp-dev libassuan-dev go-md2man btrfs-progs-dev bash
#
# RUN git clone --branch v3.3.1 --depth 1 https://github.com/containers/podman.git
#
# WORKDIR /podman
#
# ENV BUILDTAGS="exclude_graphdriver_devicemapper seccomp apparmor"
# RUN make podman
# COPY --from=config-podman /podman/bin/podman /usr/sbin/podman

FROM alpine:$ALPINE_TAG

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

EXPOSE 22
ARG VERSION=3.2.3-r1
RUN apk add --no-cache buildah podman=$VERSION iputils openssh fuse-overlayfs shadow slirp4netns sudo

RUN mv /etc/containers/storage.conf /etc/containers/storage.conf~ \
 && sed 's/#mount_program/mount_program/' /etc/containers/storage.conf~ > /etc/containers/storage.conf \
 && mv /etc/ssh/sshd_config /etc/ssh/sshd_config~ \
 && sed 's/AllowTcpForwarding no/AllowTcpForwarding all/' /etc/ssh/sshd_config~ > /etc/ssh/sshd_config \
 && ln -s /etc/builder/id_rsa /etc/ssh/ssh_host_rsa_key  \
 && ln -s /etc/builder/id_rsa.pub /etc/ssh/ssh_host_rsa_key.pub

# System keygen was used for debugging it is insecure to release with this
# RUN ssh-keygen -A \

ARG USER=bob
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "$USER:$USER" | chpasswd \
 && usermod --add-subuids 100000-165535 $USER \
 && usermod --add-subgids 100000-165535 $USER

# RUN chown $USER:$USER -R <</some/folder/path /multiple/folder/paths>>
RUN echo "%wheel         ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && usermod -aG wheel $USER

USER $USER
WORKDIR /home/bob

# dig -x 10.34.3.22 +short
# droneci-server.cicd.svc.cluster.local
RUN podman system connection add local --identity /home/bob/.ssh/id_rsa ssh://127.0.0.1:22/tmp/podman-run-1000/podman/podman.sock \
 && podman system connection add x86_64 --identity /home/bob/.ssh/id_rsa ssh://127.0.0.1:22/tmp/podman-run-1000/podman/podman.sock \
 && podman system connection add aarch64 --identity /home/bob/.ssh/id_rsa ssh://127.0.0.1:22/tmp/podman-run-1000/podman/podman.sock

# ln -s /etc/builder/id_rsa.pub /home/bob/.ssh/authorized_keys \
RUN mkdir -p /home/bob/.ssh \
 && ln -s /etc/builder/id_rsa /home/bob/.ssh/id_rsa \
 && ln -s /etc/builder/id_rsa.pub /home/bob/.ssh/id_rsa.pub
 
# Keygen was used for debugging it is insecure to release with this
#
# RUN ssh-keygen -f ~/.ssh/id_rsa -N '' \
#  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
#
#
# Plugging commands into .ash_history was for debuging and is not needed in release
#
# RUN echo "sudo /usr/sbin/sshd -De -f /etc/ssh/sshd_config" > ~/.ash_history \
#  && echo "podman system service --time 0" >> ~/.ash_history \
#  && echo "podman system connection add build --identity /home/bob/.ssh/id_rsa ssh://192.168.5.110:2222/tmp/podman-run-1000/podman/podman.sock"  >> ~/.ash_history \
#  && echo podman --remote run hello-world  >> ~/.ash_history \
 
COPY builder-base /builder-base
COPY builder-podman /builder-podman

# Default CMD is builder-base with a default 5400 (90 minutes) sleep parameter
# CMD ["/builder-base, "5400"]


