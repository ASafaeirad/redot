#!/bin/bash
set -e

echo "-------------"
echo "$HOME"
echo "-------------"

if [[ ! -d $HOME ]]; then
  echo "$HOME" is not exists.
  exit 1
fi

sudo apt update -y
sudo apt install git tmux docker.io -y

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo usermod -aG docker "$USER"
sudo systemctl enable docker
sudo systemctl start docker

BAKDIR="$HOME/redot-backup"
[[ ! -d "$BAKDIR" ]] && mkdir "$BAKDIR"
[[ -f "$HOME/.bashrc" ]] && mv "$HOME/.bashrc" "$BAKDIR/.bashrc"

GITDIR="$HOME/.redot"

mkdir -p "$GITDIR"
pushd "$GITDIR"

git init --bare
git --git-dir="$GITDIR" --work-tree="$HOME" remote add origin https://github.com/frontendmonster/redot.git
git --git-dir="$GITDIR" --work-tree="$HOME" pull origin master
