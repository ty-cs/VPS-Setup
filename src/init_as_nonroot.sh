#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ioiono/VPS-Setup/master/src/init_as_nonroot.sh)"
# or via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/ioiono/VPS-Setup/master/src/init_as_nonroot.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/ioiono/VPS-Setup/master/src/init_as_nonroot.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/ioiono/VPS-Setup/master/src/init_as_nonroot.sh -O install.sh
#   sh install.sh

set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

timedatectl set-timezone Asia/Singapore

apt-get update && apt-get install -y \
    curl \
    git \
    zsh \
    wget \
    sudo \
    vim \
    net-tools \


# shellcheck disable=SC2059
printf "\n${GREEN}Installation done.${NC}\n\n"

# run after switch user
useradd -rm -d /home/admin -s /bin/zsh -g root -G sudo -u 1000 -p "$(openssl passwd -1 admin)" admin

printf "\n${GREEN}admin created.${NC}\n\n"


ADMIN_HOME=/home/admin
export HOME=$ADMIN_HOME
export ZSH="$ADMIN_HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

printf "\nZSH: %s\n\n" "$ZSH"
printf "\nZSH_CUSTOM: %s\n\n" "$ZSH_CUSTOM"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# change default zsh theme
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="crcandy"/' ~/.zshrc
sed -i 's/^plugins=.*/plugins=(git brew docker docker-compose zsh-syntax-highlighting zsh-autosuggestions zsh-completions command-time)/' ~/.zshrc

# zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/popstas/zsh-command-time.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/command-time

{
echo "autoload -U compinit && compinit"
echo "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=\"fg=7\""
echo "ZSH_COMMAND_TIME_MIN_SECONDS=0"
echo 'ZSH_COMMAND_TIME_MSG="Execution time: %s"'
} >> $HOME/.zshrc

chown -R admin:root $ZSH
chown admin:root $HOME/.zshrc

su - admin
