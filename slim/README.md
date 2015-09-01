# Slim Dockerfile
In case this needs to be built locally, there is an unfortunate side effect that
when you build a Docker container, that all layers are separate, and that installing
and then removing the build dependencies won’t result in a reduced image.

There are two ways around this. The first is to use a single RUN command that runs
the build, and installs and then uninstalls the build deps all in the same command.

This of course results in having to maintain the build script separate of the Dockerfile
which is less than ideal.

The other method is to export and import the image after building, leaving you only with
the last layer of the Docker image.

Start up the container and get the container hash, then run the following:

`$ docker export <container_hash> | docker import - asterisk/reduced:13.1-cert2`

Just change the `asterisk/reduced` part to the repository you want to keep the new image in.
