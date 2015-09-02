# docker-certified-asterisk-13
Certified Asterisk 13 Docker Image

## Running Asterisk
The following sets of commands will show you how to use the Asterisk image along with some other supporting volume containers to get going.

### Starting up the DVC for sounds
```sh
docker run -d --name="asterisk-sounds-en" docker.io/avoxi/dvc-asterisk-sounds-en:latest

docker run -v /var/spool/asterisk \
           --name="asterisk-spool" centos:7 \
           sh -c 'echo Asterisk Spool Volume'

```

### Starting Asterisk and Mounting Volumes
```sh
docker run -ti \
           --volumes-from=asterisk-sounds-en:ro \
           --volumes-from=asterisk-spool \
           -v `pwd`/etc-asterisk:/etc/asterisk \
           docker.io/avoxi/certified-asterisk:13.1-cert2
```

## Networking Considerations
There are various methods of setting up networking with Docker, but for our purposes, it is easier to have the container to get a real IP address from our DHCP server, and then expose the ports.

In general this is not the right way to do it, but for our testing purposes, it does get us an Asterisk container up and running in a short period of time, and allows us to connect a couple of phones to it.

In order to get going in short order we can use [pipework](https://github.com/jpetazzo/pipework) to attach our container to our local LAN and request and IP address from our local DHCP server.

The following command assumes that you've passed a `--name=ast01` value to the `docker run` command. If you didn't then just pass the hash of the container that is running that you want to use dhclient for networking. The below example also assumes your LAN interface is `enp8s0`.

```sh
docker run -ti --name="ast01" --net=none \
           --volumes-from=asterisk-sounds-en:ro \
           --volumes-from=asterisk-spool \
           --expose=5060 \
           --expose=10000-20000 \
           -v `pwd`/etc-asterisk:/etc/asterisk \
           docker.io/avoxi/certified-asterisk:13.1-cert2

# detach from the container with ^P^Q

sudo pipework enp8s0 ast01 dhclient
```

Now if you attach to the running container, you will have an IP address from your local LAN.