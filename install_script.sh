#!/bin/bash
set -e

function throw() {
  echo "$1"
  exit 1
}

function mk_safe() {
  [[ ! -d "$1" ]] && mkdir "$1"
}

function mv_save() {
  [[ -f "$1" ]] && mv "$1" "$2"
}

WARN='\033[0;33m'
CYAN='\033[1;36m'
NC='\033[0m'

function title() {
  echo
  echo -e "${CYAN}==============================${NC}"
  echo -e "${CYAN}⬢ ${1}${NC}"
  echo -e "${CYAN}==============================${NC}"
  echo
}

function progress() {
  echo
  echo -e "${CYAN}⬢ ${1}${NC}"
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
  echo "-------------"
  echo "$HOME"
  echo "-------------"
}

function check_home() {
  [[ ! -d $HOME ]] && throw "$HOME is not exists."
}

function install() {
  progress "Installing $1"
  sudo apt install $1 -y
  success "$1 installed successfully"
}

function install_docker() {
  install docker.io
  sudo usermod -aG docker "$USER"
  sudo systemctl enable docker
  sudo systemctl start docker

  progress "Installing docker-compose"
  sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
  success "docker-compose installed successfully"
}

function install_packages() {
  progress "Updating repos"
  sudo apt update -y

  install git
  install tmux
  instal_docker
}

function init_redot() {
  progress "Init redot"
  local BAKDIR="$HOME/redot-backup"
  local GITDIR="$HOME/.redot"
  local GITPARAMS="--git-dir=$GITDIR --work-tree=$HOME"

  mk_safe $BAKDIR
  mv_safe "$HOME/.bashrc" "$BAKDIR/.bashrc"

  mkdir -p "$GITDIR"
  pushd "$GITDIR"
  git init --bare
  popd

  git $GITPARAMS remote add origin https://github.com/frontendmonster/redot.git
  git $GITPARAMS pull origin master
  git $GITPARAMS branch --set-upstream-to origin/master master
}

print_banner
print_env
install_packages
init_redot
