ARG ALPINE_TAG=3.14.1
FROM alpine:$ALPINE_TAG as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:$ALPINE_TAG

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

ARG VERSION=3.2.3-r1
RUN apk add --no-cache buildah podman=$VERSION git iputils openssh fuse-overlayfs shadow slirp4netns sudo

# RUN mv /etc/containers/storage.conf /etc/containers/storage.conf~ \
#  && sed 's/#mount_program/mount_program/' /etc/containers/storage.conf~ > /etc/containers/storage.conf \
#  && mv /etc/ssh/sshd_config /etc/ssh/sshd_config~ \
#  && sed 's/AllowTcpForwarding no/AllowTcpForwarding all/' /etc/ssh/sshd_config~ > /etc/ssh/sshd_config

#  && cp /etc/ssh/sshd_config /etc/ssh/sshd_config~ \
#  && echo "StrictModes no" >> /etc/ssh/sshd_config \
#  && ln -s /etc/builder/id_rsa /etc/ssh/ssh_host_rsa_key  \
#  && ln -s /etc/builder/id_rsa.pub /etc/ssh/ssh_host_rsa_key.pub
# System keygen was used for debugging it is insecure to release with this
# RUN ssh-keygen -A \

ARG USER=bob
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "$USER:$USER" | chpasswd
 # \
 # && usermod --add-subuids 100000-165535 $USER \
 # && usermod --add-subgids 100000-165535 $USER

# RUN chown $USER:$USER -R <</some/folder/path /multiple/folder/paths>>
RUN echo "%wheel         ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && usermod -aG wheel $USER

USER $USER
WORKDIR /home/bob

RUN podman system connection add x86 --identity /home/bob/.ssh/podman_key_x86 ssh://podman@podman-x86.cicd.svc.cluster.local:22/tmp/podman-run-1000/podman/podman.sock \
 && podman system connection add arm --identity /home/bob/.ssh/podman_key_arm ssh://podman@podman-arm.cicd.svc.cluster.local:22/tmp/podman-run-1000/podman/podman.sock
 
# podman --remote -c test rmi --force $(podman --remote -c test images -q)


# ln -s /etc/builder/id_rsa.pub /home/bob/.ssh/authorized_keys \
# RUN mkdir -p /home/bob/.ssh \
#  && ln -s /etc/builder/id_rsa /home/bob/.ssh/id_rsa \
#  && ln -s /etc/builder/id_rsa.pub /home/bob/.ssh/id_rsa.pub
 
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
# COPY builder-podman /builder-podman

# Take-out
# Default entrypoint is builder-base with a default 5400 (90 minutes) sleep parameter. You can overload on run with entrypoint.
# ENTRYPOINT ["/builder-base", "5400"]


