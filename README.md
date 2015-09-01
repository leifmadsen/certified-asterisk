# docker-certified-asterisk-13
Certified Asterisk 13 Docker Image

## Running Asterisk
The following sets of commands will show you how to use the Asterisk image along with some other supporting volume containers to get going.

### Starting up the DVC for sounds
```sh
docker run -d --name="asterisk-sounds-en" avoxi/dvc-asterisk-sounds-en:latest

docker run -v /var/spool/asterisk \
           --name="asterisk-spool" centos:7 \
           sh -c 'echo Asterisk Spool Volume'

```

### Starting Asterisk and Mounting Volumes
```sh
docker run -ti \
           --volumes-from=asterisk-sounds-en \
           --volumes-from=asterisk-spool \
           -v `pwd`/etc-asterisk:/etc/asterisk \
           avoxi/certified-asterisk:13.1-cert2
```
