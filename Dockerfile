FROM ubuntu:22.04

ENV LANG=C.UTF-8

ARG USER_NAME
ONBUILD ARG USER_NAME

ARG USER_ID
ONBUILD ARG USER_ID

ARG DOCKER_GROUP_ID
ONBUILD ARG DOCKER_GROUP_ID

ARG DEBIAN_FRONTEND
ONBUILD ARG DEBIAN_FRONTEND
ENV DEBIAN_FRONTEND=$DEBIAN_FRONTEND

ARG TZ
ONBUILD ARG TZ
ENV TZ=$TZ

ARG XDG_RUNTIME_DIR
ONBUILD ARG XDG_RUNTIME_DIR
ENV XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR

##
## Root phase
##

# Update packages
RUN apt update && \
apt upgrade -y --no-install-recommends && \
# Install packages from the repositories
apt install -y --no-install-recommends \
sudo \
curl \
rlwrap \
gnupg \
fonts-ubuntu \
gnupg-agent \
apt-transport-https \
ca-certificates \
software-properties-common \
git \
openjdk-17-jdk \
zsh \
cloc \
tree && \
# Docker
groupadd -g $DOCKER_GROUP_ID docker && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
apt update && \
apt install -y docker-ce docker-ce-cli containerd.io && \
# Docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose && \
# Node
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - && \
sudo apt install -y nodejs && \
# Google Chrome
curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o chrome.deb && \
apt install -y ./chrome.deb && \
rm chrome.deb && \
# Clojure
curl -O https://download.clojure.org/install/linux-install-1.10.3.1029.sh && \
chmod +x linux-install-1.10.3.1029.sh && \
./linux-install-1.10.3.1029.sh && \
rm linux-install-1.10.3.1029.sh && \
# Visual Studio Code
curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -o code.deb && \
apt install -y ./code.deb && \
rm code.deb && \
# IntelliJ Idea
curl -L https://download.jetbrains.com/idea/ideaIC-213.5744.202.tar.gz -o idea.tar.gz && \
tar -xvzf idea.tar.gz && \
mv idea-IC-213.5744.202 /opt/idea && \
ln -s /opt/idea/bin/idea.sh /usr/local/bin/idea && \
rm idea.tar.gz && \
# Add a user
useradd -m -s /bin/zsh -u $USER_ID -G sudo,docker $USER_NAME && \
mkdir -p $XDG_RUNTIME_DIR && \
chown $USER_NAME:$USER_NAME $XDG_RUNTIME_DIR

#
# User phase
#
USER $USER_NAME
WORKDIR /home/$USER_NAME
