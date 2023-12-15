# Dev-env

**Deprecated: see [Realms](https://github.com/MattiNieminen/realms)
for better approach.**

My isolated and extendable software development environment with automated and
repeatable installation.

Implemented using Docker. Host must be running Wayland for this to work.

* Git (shared configuration with host).
* Zsh (shared configuration with host).
* JDK.
* Javascript, Node, NPM.
* Clojure(script) and related CLI Tools.
* Visual Studio Code.
* IntelliJ Idea.
* Google Chrome.
* Various utilities.

The home directory of the user inside the container is mounted as a named
volume, meaning that files in home directory are saved even between image
builds and container restarts.

This image can be also used as a parent image for more specific development
enviroments.

## Usage

Create a symbolic link for running the container from anywhere:

```bash
sudo ln -s "$(pwd)/dev-env.sh" /usr/local/bin/dev-env.sh
```

The linked script builds the image if necessary and makes sure that only a
single container is running at all times.

After linking the script it can be run with:

```bash
dev-env.sh
```

### Child images

See ```dev-env.sh --help``` for instructions how to select the build directory
and give a distinct name for the image and the container. Below is an example
Dockerfile that uses JDK 8 instead of the default version:

```
FROM my-dev-env:latest

##
## Root phase
##
USER root
WORKDIR /
# Java 8
RUN apt-get install -y --no-install-recommends openjdk-8-jdk && \
update-java-alternatives -s java-1.8.0-openjdk-amd64

#
# User phase
#
USER $USER_NAME
WORKDIR /home/$USER_NAME
```

To build an extended version of the default development environment, first
build the parent image by running ```dev-env.sh``` normally. Then build the
child image with the command below:

```bash
dev-env.sh --build [PATH-TO-DIR-WITH-ABOVE-DOCKERFILE] --name jdk8-dev-env
```

To run the container later, use the command below:

```bash
dev-env.sh --name jdk8-dev-env
```
