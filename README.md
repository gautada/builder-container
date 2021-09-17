# builder-container

This is a collection of tools to build OCI containers inside my k8s cluster.  This is made up of several applications and their and their dependencies:

- [Buildah](https://buildah.io) - A tool that facilitates building OCI container images. +[repository](https://github.com/containers/buildah)+
-[Podman](https://podman.io) is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System.

## Container

### Versions

  - September 14, 2021 [podman](https://podman.io/releases/) - Active version is [3.2 .3](https://pkgs.alpinelinux.org/packages?name=podman&branch=edge)

### Manual
  
#### Build

```
docker build --build-arg ALPINE_TAG=3.14.2 --build-arg VERSION=3.2.3-r1 --file Containerfile --no-cache --tag builder:dev . 
```
  
#### Run

Builder base mode runs the container for 5400 seconds (90 minutes). Basically launch and do nothing  

```
docker run -it -d --name builder --privileged --rm builder:dev
```

#### Deploy

```
docker login
docker tag builder:dev docker.io/gautada/builder:3.2.3-r1-aarch64
docker push docker.io/gautada/builder:3.2.3-r1-aarch64
```


Launch the SSH service to support the bastion. Add the -d flag for debug mode but it shutdown after each call
```
docker exec -it builder sudo /usr/bin/ssh-keygen -A
docker exec -it builder sudo /usr/sbin/sshd -De -f /etc/ssh/sshd_config
```

Launch the podman API service. Time is set to 0 for no timeout
```
docker exec -it  builder /usr/bin/podman --log-level trace system service --time 0
```

Launch the remote client to run a container via (ssh)podman api service
```
docker exec -it builder /usr/bin/podman --remote run hello-world
```

Just run the ssh and api service from the get go.
```
docker run -it --name builder --privileged --rm builder:dev /builder-podman 86400
```

Secrets can provide the required ssh credentials but these needed to be manually entered into the droneci db using base64

```
sqlite3 core.sqlite "UPDATE orgsecrets SET secret_data='$(cat ./id_rsa | base64 )' WHERE secret_id=11;"
```

To decode the data use base64 -d
```
echo -n $ID_RSA_KEY | base64 -d >  /home/bob/.ssh/id_rsa
```

put in the environment variable using the `DroneCI.yaml` file.
```
...
ID_RSA_KEY_PUB:
  from_secret: podman.ssh.pkey
...
```

Manual build of the x86 container
```
export DOCKER_HOST=192.168.4.204
docker build --build-arg ALPINE_TAG=3.14.2 --build-arg VERSION=3.2.3-r1 --file Containerfile --no-cache --tag builder:dev . 
docker tag builder:dev docker.io/gautada/builder:3.2.3-r1-x86_64
docker push docker.io/gautada/builder:3.2.3-r1-x86_64
```

## Commands

To launch the podman API service
```
podman system service --time 0
```

To test a local version of podman service
```
curl --unix-socket /tmp/podman-run-1000/podman/podman.sock http://localhost/_ping
```

## Configuration

### SSH

SSH must have the `/etc/ssh/sshd_config` set to `AllowTCPForwarding all`

### Podman

Podman remote connection configuration `podman system connection add build <--identity <path to priv key> ssh://<<ip/domain>>:<<port>>/tmp/podman-run-1000/podman/podman.sock`

## Notes

- [Podman inside Kubernets](https://www.redhat.com/sysadmin/podman-inside-kubernetes)
- [Podman System Service](https://docs.podman.io/en/latest/markdown/podman-system-service.1.html)
- [Podman Remote Service](https://github.com/containers/podman/blob/main/docs/tutorials/remote_client.md)
- [Podman Stuff](https://wiki.alpinelinux.org/wiki/Podman)
- [Podman Service Issues](https://github.com/containers/podman/issues/11398)
- [Run podman in a container](https://www.redhat.com/sysadmin/podman-inside-container)
    
https://www.cloudassembler.com/post/remote-podman-service/
    
Test 567 - Run the sshd server with -D flag and verbose, exec podman service,  try to connect with remote client.



podman system connection add test --identity ~/.ssh/id_rsa ssh://root@192.168.5.110:2222/run/podman/podman.sock  

