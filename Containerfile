ARG ALPINE_TAG=3.14.1

FROM alpine:$ALPINE_TAG

EXPOSE 22
EXPOSE 6625

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

RUN apk add --no-cache buildah iputils podman openssh fuse-overlayfs shadow slirp4netns sudo

# RUN mv /etc/containers/storage.conf /etc/containers/storage.conf~ \
#  && sed 's/#mount_program/mount_program/' /etc/containers/storage.conf~ > /etc/containers/storage.conf \
#  && chmod 4755 /usr/bin/newgidmap \
#  && chmod 4755 /usr/bin/newuidmap

# RUN modprobe tun

RUN ssh-keygen -A

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

RUN ssh-keygen -f /home/bob/.ssh/id_rsa -N '' \
 && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

COPY Test.Containerfile /home/bob/Containerfile

RUN echo "buildah images" > ~/.ash_history \
 && echo "buildah bud --file Containerfile --tag localhost/bob:test" >> ~/.ash_history \
 && echo "buildah login" >> ~/.ash_history \
 && echo "buildah push localhost/bob:test docker://docker.io/gautada/bob:test" >> ~/.ash_history \
 && echo "sudo /usr/sbin/sshd -e -f /etc/ssh/sshd_config" >> ~/.ash_history \
 && echo "podman system service --time 0" >> ~/.ash_history
 
# Sleep for an hour and a half (90 minutes)
CMD ["/bin/sleep", "5400"]
# CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]
#
#
