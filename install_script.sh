#!/bin/bash
set -e

HOMEDIR=${1:-$HOME}

echo "-------------"
echo "$HOMEDIR"
echo "-------------"

if [[ "$EUID" -ne 0 ]]; then
  echo "Sorry, this script must be ran as root"
  echo "Maybe try this:"
  echo "curl https://raw.githubusercontent.com/frontendmonster/redot/master/install_script.sh | sudo bash"
  exit 1
fi

if [[ ! -d $HOMEDIR ]]; then
  echo "$HOMEDIR" is not exists.
  exit 1
fi

apt update -y
apt install git tmux docker.io -y

curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

BAKDIR="$HOMEDIR/redot-backup"
[[ ! -d "$BAKDIR" ]] && mkdir "$BAKDIR"
[[ -f "$HOMEDIR/.bashrc" ]] && mv "$HOMEDIR/.bashrc" "$BAKDIR/.bashrc"

GITDIR="$HOMEDIR/.redot"

mkdir -p "$GITDIR"
pushd "$GITDIR"

git init --bare
git --git-dir="$GITDIR" --work-tree="$HOMEDIR" remote add origin https://github.com/frontendmonster/redot.git
git --git-dir="$GITDIR" --work-tree="$HOMEDIR" pull origin master -u
