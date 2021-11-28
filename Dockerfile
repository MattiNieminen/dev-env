FROM ubuntu:21.10

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

##
## Root phase
##

# Update packages
RUN apt-get update && \
apt-get upgrade -y --no-install-recommends && \
# Install packages from the repositories
apt-get install -y --no-install-recommends \
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
openjdk-11-jdk \
maven \
leiningen \
zsh \
emacs \
cloc && \
# Docker
groupadd -g $DOCKER_GROUP_ID docker && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
apt-get update && \
apt-get install -y docker-ce docker-ce-cli containerd.io && \
# Docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
chmod +x /usr/local/bin/docker-compose && \
# Google Chrome
curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
apt install -y ./google-chrome-stable_current_amd64.deb && \
# Install Clojure
curl -O https://download.clojure.org/install/linux-install-1.10.2.774.sh && \
chmod +x linux-install-1.10.2.774.sh && \
./linux-install-1.10.2.774.sh && \
rm linux-install-1.10.2.774.sh && \
# Node
curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
sudo apt-get install -y nodejs && \
# Add a user
useradd -m -s /bin/zsh -u $USER_ID -G sudo,docker $USER_NAME

#
# User phase
#
USER $USER_NAME
WORKDIR /home/$USER_NAME
# Spacemacs
RUN git clone -b develop https://github.com/syl20bnr/spacemacs ~/.emacs.d
