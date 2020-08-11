#!/bin/bash
set -e

DOCKER_COMPOSE_VERSION=1.25.5
ARCH=$(uname -m)
BAK_DIR="$HOME/redot-backup"
KERNEL=$(uname -s)
CODE_NAME=$(lsb_release -cs)
WARN='\033[0;33m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'

function throw() {
  echo "$1"
  exit 1
}

function mk_safe() {
  [[ ! -d "$1" ]] && mkdir -p "$1"
}

function mv_safe() {
  [[ -f "$1" ]] && mv "$1" "$2"
}

function progress() {
  echo
  echo -e "${CYAN}==============================${NC}"
  echo -e "${CYAN}⬢ ${1}${NC}"
  echo -e "${CYAN}==============================${NC}"
  echo
}

function success() {
  echo
  echo -e "${GREEN}✓ ${1}${NC}"
  echo
}

function warn() {
  echo
  echo -e "${WARN}⬢ ${1}${NC}"
  echo
}

function print_banner() {
  echo
  echo "___ ___ ___   ___ _____"
  echo "| _ \ __|   \ / _ \_   _|"
  echo "|   / _|| |) | (_) || |"
  echo "|_|_\___|___/ \___/ |_|"
  echo
}

function print_env() {
  echo -e "${WARN}$1:${NC} ${2}"
}

function print_envs() {
  progress "Environment"
  print_env "kernel" $KERNEL
  print_env "arch" $ARCH
  print_env "codename" $CODE_NAME
  print_env "home" $HOME
  print_env "backup dir" $BAK_DIR
  print_env "docker-compose version" $DOCKER_COMPOSE_VERSION
}

function check_home() {
  [[ ! -d $HOME ]] && throw "$HOME is not exists."
}

function install() {
  progress "Installing $1"
  sudo apt-get install "$1" -qy
  success "$1 installed successfully"
}

function install_docker() {
  progress "Installing docker"
  local DOCKER_ARCH
  if [ $ARCH = 'x86_64' ]; then
    DOCKER_ARCH='amd64'
  fi

  sudo apt-get remove docker docker-engine docker.io containerd runc -qy
  success "old docker version cleaned"

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  success "docker gpg keys added successfully"
  sudo apt-get update
  sudo add-apt-repository "deb [arch=$DOCKER_ARCH] https://download.docker.com/linux/ubuntu $CODE_NAME stable"
  success "docker repos added successfully"

  sudo apt-get update
  sudo apt-get install -qy docker-ce docker-ce-cli containerd.io
  success "docker gpg keys added successfully"

  sudo usermod -aG docker "$USER"
  success "\"$USER\" user successfully added to docker group"

  sudo systemctl enable docker
  sudo systemctl start docker
  success "docker service successfully initiated"
}

function install_docker_compose() {
  progress "Installing docker-compose"
  local DOCKER_COMPOSE_PATH="/usr/local/bin/docker-compose"
  sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$KERNEL-${ARCH}" \
    -o $DOCKER_COMPOSE_PATH
  sudo chmod +x $DOCKER_COMPOSE_PATH
  sudo ln -sf $DOCKER_COMPOSE_PATH /usr/bin/docker-compose
  success "docker-compose installed successfully"
}

function install_packages() {
  progress "Updating repos"
  sudo apt-get update

  install apt-transport-https
  install ca-certificates
  install gnupg-agent
  install software-properties-common
  install git
  install tmux
  install_docker
  install_docker_compose
}

function backup() {
  mv_safe "$HOME/$1" "$BAK_DIR/$1"
  success "Backup $1"
}

function remove_packages {
  sudo apt-get remove command-not-found command-not-found-data -qy
}

function cleanup() {
  rm "$HOME/README.md"
  rm "$HOME/install_script.sh"
	rm "$HOME/.editorconfig"
}

function init_redot() {
  progress "Init redot"
  local GIT_DIR="$HOME/.redot"
  local GIT_PARAMS="--git-dir=$GIT_DIR --work-tree=$HOME"

  mk_safe "$BAK_DIR"
  backup ".bashrc"

  mkdir -p "$GIT_DIR"
  pushd "$GIT_DIR"
  git init --bare
  popd
  success "$GIT_DIR repo created"

  git $GIT_PARAMS remote add origin https://github.com/frontendmonster/redot.git
  git $GIT_PARAMS pull origin master
  git $GIT_PARAMS branch --set-upstream-to origin/master master
  success "redot repo updated successfully"
}

init() {
  print_banner
  print_envs
  remove_packages
  install_packages
  init_redot
  cleanup
}

init
