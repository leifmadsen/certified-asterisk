# Certified Asterisk Docker Image (unofficial)
Docker image for Certified Asterisk 13 (unofficial package). Maintained by AVOXI. Primary purpose is for use during [AstriCon 2015](http://astricon.net) presentation.

## Running Asterisk
The following sets of commands will show you how to use the Asterisk image along with some other supporting volume containers to get going.

### Starting up the data volumes

First we'll start up a few Docker Volume Containers (DVC). These are pre-built volume containers that host the sound prompts and music on hold files for Asterisk.

> The sound prompts in the example are English prompts, both core and extras, with formats `G.729`, `SLIN`, and `WAV`.
> Files in the MOH volume are same formats, using the opsound files from Digium.

#### Start Docker Volume Containers
```sh
docker run -d --name="asterisk-sounds-en" docker.io/avoxi/asterisk-sounds-en:latest
docker run -d --name="asterisk-moh" docker.io/avoxi/asterisk-moh:latest
```

#### Create volume containers for Asterisk data
```sh
docker run -v /var/spool/asterisk \
           --name="asterisk-spool" centos:7 \
           sh -c 'echo Asterisk Spool Volume'

```

### Starting Asterisk and Mounting Volumes
```sh
docker run -ti \
           --volumes-from=asterisk-sounds-en:ro \
           --volumes-from=asterisk-moh:ro \
           --volumes-from=asterisk-spool \
           -v `pwd`/etc-asterisk:/etc/asterisk \
           docker.io/avoxi/certified-asterisk:latest
```

## Networking Considerations
There are various methods of setting up networking with Docker, but for our purposes, it is easier to have the container to get a real IP address from our DHCP server, and then expose the ports.

In general this is not the right way to do it, but for our testing purposes, it does get us an Asterisk container up and running in a short period of time, and allows us to connect a couple of phones to it.

In order to get going in short order we can use [pipework](https://github.com/jpetazzo/pipework) to attach our container to our local LAN and request and IP address from our local DHCP server.

The following command assumes that you've passed a `--name=ast01` value to the `docker run` command. If you didn't then just pass the hash of the container that is running that you want to use dhclient for networking. The below example also assumes your LAN interface is `enp8s0`.

```sh
docker run -ti --name="ast01" \
           --hostname="ast01" --add-host="ast01:127.0.0.1" --net=none \
           --volumes-from=asterisk-sounds-en:ro \
           --volumes-from=asterisk-moh:ro \
           --volumes-from=asterisk-spool \
           --expose=5060 \
           --expose=10000-20000 \
           -v `pwd`/etc-asterisk:/etc/asterisk \
           docker.io/avoxi/certified-asterisk:latest

# detach from the container with ^P^Q

sudo pipework enp8s0 ast01 dhclient
```

Now if you attach to the running container, you will have an IP address from your local LAN.

### Hostname Gotcha
You are likely to see a message if you don't setup the `/etc/hosts` file to have the containers hostname configured:
```
getaddrinfo("896f1da008b0", "(null)", ...): No address associated with hostname
Unable to lookup '896f1da008b0'
```
We specify a hostname using the `--hostname` (`/etc/hostname`) and local hostname resolution using the `--add-host` (`/etc/hosts`) flags. Without this the `/etc/hostname` will simply be the container ID.

You can still resolve this by adding the container ID (`896f1da008b0`) to the `/etc/hosts` file on the system.

From the Asterisk `*CLI>` run:
```
*CLI> !vi /etc/hosts
```

None of this should be necessary though if you use the flags as indicated.
