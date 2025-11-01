#!/bin/bash

echo 'Anu installer'

DP=$([[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] && echo true || echo false)
if [ $DP == false ]; then
    echo "This script works only in Gnome environment"
    exit 1
fi

echo -e 'Start default upgrade'
sudo apt update
sudo apt upgrade -y
echo -e ''
sleep 1

echo -e 'Start default upgrade'
sudo apt install curl wget git -y
sudo apt install chrome-gnome-shell -y
sudo apt install gnome-browser-connector -y
sudo apt install gnome-shell-extension-manager
echo -e ''
sleep 1

echo -e 'Install needed dependencies'
sudo wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
sudo echo 'deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list
sudo apt update && sudo apt install codium
echo -e ''

echo -e 'Install other tools'
curl -sS https://starship.rs/install.sh | sh
curl -fsS https://dl.brave.com/install.sh | sh
echo -e ''

echo -e 'Install codium depedencies'
codium --install-extension akamud.vscode-theme-onelight
codium --install-extension catppuccin.catppuccin-vsc
codium --install-extension catppuccin.catppuccin-vsc-icons
codium --install-extension vadimcn.vscode-lldb
codium --install-extension ms-azuretools.vscode-containers
codium --install-extension ms-azuretools.vscode-docker
codium --install-extension golang.go
codium --install-extension ziglang.vscode-zig
codium --install-extension dreamcatcher45.podmanager
codium --install-extension cweijan.vscode-redis-client
codium --install-extension mtxr.sqltools
codium --install-extension vscode-icons-team.vscode-icons
codium --install-extension antfu.icons-carbon
codium --install-extension alexdauenhauer.catppuccin-noctis-icons
codium --install-extension donjayamanne.githistory
codium --install-extension shd101wyy.markdown-preview-enhanced
codium --install-extension esbenp.prettier-vscode
echo -e ''

echo -e 'Download necessary gnome-extensions'
wget https://extensions.gnome.org/extension-data/openbarneuromorph.v35.shell-extension.zip
gnome-extensions install openbarneuromorph.v35.shell-extension.zip --force

wget https://extensions.gnome.org/extension-data/tilingshellferrarodomenico.com.v12.shell-extension.zip
gnome-extensions install tilingshellferrarodomenico.com.v12.shell-extension.zip --force

wget https://extensions.gnome.org/extension-data/VitalsCoreCoding.com.v68.shell-extension.zip
gnome-extensions install VitalsCoreCoding.com.v68.shell-extension.zip --force

wget https://extensions.gnome.org/extension-data/appindicatorsupportrgcjonas.gmail.com.v58.shell-extension.zip
gnome-extensions install appindicatorsupportrgcjonas.gmail.com.v58.shell-extension.zip --force

echo -e 'Download necessary gnome apps'
wget https://github.com/Ulauncher/Ulauncher/releases/download/5.15.7/ulauncher_5.15.7_all.deb
sudo apt install ./ulauncher_5.15.7_all.deb -y
mkdir ~/.config/autostart
cp config/ulauncher.desktop ~/.config/autostart/
echo -e ''

echo - e 'Load adwaita blue theme'
git clone https://github.com/ricardoherreramx/adwaitaru.git
mkdir ~/.icons
cp -r adwaitaru/Adwaitaru-blue .icons/
echo -e ''

echo -e 'Load gnome keyboard shortcuts and pre-settings'
dconf load / < config/dconf-settings.ini
echo -e ''
sleep 1

echo -e 'Install zig'
wget https://ziglang.org/download/0.15.1/zig-x86_64-linux-0.15.1.tar.xz
sudo tar -C /usr/local/ -xf zig-x86_64-linux-0.15.1.tar.xz 
sudo mv /usr/local/zig-x86_64-linux-0.15.1.tar.xz /usr/local/zig
echo 'export ZIG=/usr/local/zig' >> ~/.bashrc
echo 'export PATH=$ZIG:$PATH' >> ~/.bashrc
echo -e ''

echo -e 'Install Go'
wget https://go.dev/dl/go1.25.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.25.3.linux-amd64.tar.gz
echo 'export GO=/usr/local/go' >> ~/.bashrc
echo 'export PATH=$GO:$PATH' >> ~/.bashrc
echo -e ''

echo -e 'Remove downloaded dependencies'
rm openbarneuromorph.v35.shell-extension.zip
rm tilingshellferrarodomenico.com.v12.shell-extension.zip
rm VitalsCoreCoding.com.v68.shell-extension.zip
rm appindicatorsupportrgcjonas.gmail.com.v58.shell-extension.zip
rm ulauncher_5.15.7_all.deb
rm -rf adwaitaru
rm -rf zig-x86_64-linux-0.15.1.tar.xz
rm -rf go1.25.3.linux-amd64.tar.gz
echo -e ''

echo -e "Clean up done"
sleep 1

echo -e "Anu installation completed"
sleep 2

gnome-session-quit --force