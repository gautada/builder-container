# builder-container

This is a collection of tools to build OCI containers inside my k8s cluster.  This is made up of several projects:

- [Buildah](https://buildah.io) - A tool that facilitates building OCI container images. +[repository](https://github.com/containers/buildah)+
-[Podman](https://podman.io) is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System. Containers can either be run as root or in rootless mode.+[repository](https://github.com/containers/podman)+
  
[Podman in a rootless environment](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)

https://www.redhat.com/sysadmin/podman-inside-kubernetes

## Development

### Manual Build

The builder container is a cornerstone component to the cicd system.  Therefore, sometimes the container must be built and deployed manually to get the initial system bootstrapped. 

```
docker build --no-cache --tag builder:dev .
docker run -d --name builder builder:dev
BUILDAH_VERSION=$(docker exec -i -t builder /usr/bin/buildah --version | cut -d' ' -f3 | sed 's/ *$//g')
PODMAN_VERSION=$(docker exec -i -t builder /usr/bin/podman --version | cut -d' ' -f3 | sed 's/ *$//g')
VERSION="v${BUILDAH_VERSION}_v${PODMAN_VERSION//[$'\t\r\n ']}"
docker tag builder:dev gautada/builder:$VERSION
docker push gautada/builder:$VERSION
docker stop builder
docker rm builder
```
