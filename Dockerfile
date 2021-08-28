FROM alpine:3.14.1

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

RUN apk add --no-cache buildah podman iputils

RUN mv /etc/containers/storage.conf /etc/containers/storage.conf~ \
 && sed 's/#mount_program/mount_program/' /etc/containers/storage.conf~ > /etc/containers/storage.conf \
 && echo "bob:10000:65536" >> /etc/subuid \
 && echo "bob:10000:65536" >> /etc/subgid

ARG USER=bob
RUN addgroup $USER \
 && adduser -D -s /bin/sh -G $USER $USER \
 && echo "$USER:$USER" | chpasswd

# RUN chown $USER:$USER -R <</some/folder/path /multiple/folder/paths>>

USER $USER
WORKDIR /home/bob

COPY Test.Containerfile /home/bob/Containerfile
RUN echo "buildah images" > ~/.ash_history \
 && echo "buildah bud --file Containerfile --tag localhost/bob:test" > ~/.ash_history \
 && echo "buildah login" > ~/.ash_history \
 && echo "buildah push localhost/bob:test docker://docker.io/gautada/bob:test" > ~/.ash_history

CMD ["/usr/bin/tail", "-f", "/dev/null"]
