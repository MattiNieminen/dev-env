#!/bin/bash

set -e

die() {
  echo "$1" >&2
  exit 1
}

help() {
  cat << EOF
Usage: ${0##*/} [--build [DIRECTORY]] [--name IMAGE_NAME]
Runs a Docker container for my personal development environment.

Also builds the image if an image with the same name does not already exist.
Option --build can be used to specify the build directory and force rebuilding.
See README.md for additional information.

  --help                 display this help and exit.
  --build [DIRECTORY]    build the image inside DIRECTORY (defaults to current dir).
                         Rebuilds if the image with the same name already exists.
  --name IMAGE_NAME      override the name for the image, container and volume.
EOF
}

delete_image() {
  if [[ "$(docker images -q $name 2> /dev/null)" != "" ]]; then
    docker rmi "$name"
  fi
}

build_image() {
  if [[ "$rebuild_image" == "true" ]]; then
    delete_image
  fi

  if [[ "$(docker images -q $name 2> /dev/null)" == "" ]]; then
    docker build \
      --build-arg USER_NAME="$user_name" \
      --build-arg USER_ID="$user_id" \
      --build-arg DOCKER_GROUP_ID="$docker_group_id" \
      --build-arg DEBIAN_FRONTEND="noninteractive" \
      --build-arg TZ="$timezone" \
      -t "$name" "$build_dir"
  fi
}

run_container() {
  if [[ "$(docker ps -q -f status=running -f name=$name)" == "" ]]; then
    docker run -it --rm \
      --privileged \
      --network=host \
      --mount type=bind,source=/tmp/.X11-unix,target=/tmp/.X11-unix \
      --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
      -e DISPLAY="unix$DISPLAY" \
      --user "$user_id" \
      --name "$name" \
      --mount type=volume,source="$name",target="$home_inside/" \
      --mount type=bind,source="$HOME/.gitconfig",target="$home_inside/.gitconfig" \
      --mount type=bind,source="$HOME/.git-credentials",target="$home_inside/.git-credentials" \
      --mount type=bind,source="$HOME/.zshrc",target="$home_inside/.zshrc" \
      --mount type=bind,source="$HOME/.zsh",target="$home_inside/.zsh" \
      --mount type=bind,source="$HOME/.zsh_history",target="$home_inside/.zsh_history" \
      --mount type=bind,source="$HOME/.spacemacs",target="$home_inside/.spacemacs" \
      --mount type=bind,source="$HOME/workspace",target="$home_inside/workspace" \
      "$name" \
      zsh -c "$zsh_command"
  else
    docker exec -it "$name" zsh -c "$zsh_command"
  fi
}

parse_params() {
  name="my-dev-env"
  build_dir=.
  rebuild_image="false"
  user_name="$(whoami)"
  user_id="$(id -u)"
  docker_group_id="$(cut -d: -f3 < <(getent group docker))"
  home_inside="/home/$user_name"
  timezone="$(cat /etc/timezone)"
  current_dir="$(pwd)"
  zsh_command="[ -d $current_dir ] && cd $current_dir; zsh"

  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        help
        exit 0
        ;;
      --build)
        if [ "$2" ]; then
          rebuild_image="true"
          build_dir="$2"
          shift 2
        else
          die "ERROR: --build-dir requires a non-empty option argument."
        fi
        ;;
      --name)
        if [ "$2" ]; then
          name="$2"
          shift 2
        else
          die "ERROR: --name requires a non-empty option argument."
        fi
        ;;
      -*|--*)
        die "ERROR: Unknown option: $1."
        ;;
      *)
        die "ERROR: Unknown argument: $1."
        ;;
    esac
  done
}

parse_params "$@"
build_image
run_container
