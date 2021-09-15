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

curl --unix-socket /tmp/podman-run-1000/podman/podman.sock http://localhost/_ping


https://docs.podman.io/en/latest/markdown/podman-system-service.1.html
https://github.com/containers/podman/blob/main/docs/tutorials/remote_client.md
https://wiki.alpinelinux.org/wiki/Podman
https://github.com/containers/podman/issues/11398
    
    https://www.redhat.com/sysadmin/podman-inside-container
    
https://www.cloudassembler.com/post/remote-podman-service/
    
Test 567 - Run the sshd server with -D flag and verbose, exec podman service,  try to connect with remote client.



podman system connection add test --identity ~/.ssh/id_rsa ssh://root@192.168.5.110:2222/run/podman/podman.sock  

