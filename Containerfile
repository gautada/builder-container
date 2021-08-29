ARG ALPINE_TAG=3.14.1

FROM alpine:$ALPINE_TAG

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

RUN apk add --no-cache buildah podman iputils

RUN mv /etc/containers/storage.conf /etc/containers/storage.conf~ \
 && sed 's/#mount_program/mount_program/' /etc/containers/storage.conf~ > /etc/containers/storage.conf \
 && echo "bob:10000:65536" >> /etc/subuid \
 && echo "bob:10000:65536" >> /etc/subgid \
 && chmod 4755 /usr/bin/newgidmap \
 && chmod 4755 /usr/bin/newuidmap

ARG USER=bob
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "$USER:$USER" | chpasswd

# RUN chown $USER:$USER -R <</some/folder/path /multiple/folder/paths>>

USER $USER
WORKDIR /home/bob

COPY Test.Containerfile /home/bob/Containerfile

RUN echo "buildah images" > ~/.ash_history \
 && echo "buildah bud --file Containerfile --tag localhost/bob:test" >> ~/.ash_history \
 && echo "buildah login" >> ~/.ash_history \
 && echo "buildah push localhost/bob:test docker://docker.io/gautada/bob:test" >> ~/.ash_history

# Sleep for an hour and a half (90 minutes)
CMD ["/bin/sleep", "5400"]
