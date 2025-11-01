#!/bin/bash

echo -e 'Restoring default Gnome session'
echo -e ''

echo -e 'Uninstall codium depedencies'
codium --uninstall-extension akamud.vscode-theme-onelight
codium --uninstall-extension catppuccin.catppuccin-vsc
codium --uninstall-extension catppuccin.catppuccin-vsc-icons
codium --uninstall-extension vadimcn.vscode-lldb
codium --uninstall-extension ms-azuretools.vscode-docker
codium --uninstall-extension ms-azuretools.vscode-containers
codium --uninstall-extension golang.go
codium --uninstall-extension ziglang.vscode-zig
codium --uninstall-extension dreamcatcher45.podmanager
codium --uninstall-extension cweijan.vscode-redis-client
codium --uninstall-extension mtxr.sqltools
codium --uninstall-extension vscode-icons-team.vscode-icons
codium --uninstall-extension antfu.icons-carbon
codium --uninstall-extension alexdauenhauer.catppuccin-noctis-icons
codium --uninstall-extension donjayamanne.githistory
codium --uninstall-extension shd101wyy.markdown-preview-enhanced
codium --uninstall-extension esbenp.prettier-vscode
echo -e ''

echo -e 'Removing dependency softwares'
sudo apt autoremove wget -y
sudo apt autoremove chrome-gnome-shell -y
sudo apt autoremove gnome-browser-connector -y
sudo apt autoremove ulauncher -y
sudo apt autoremove gnome-shell-extension-manager -y
sudo apt autoremove codium -y
echo -e ''
sleep 1

echo -e 'Removing extensions'
gnome-extensions uninstall Vitals@CoreCoding.com --quiet
gnome-extensions uninstall tilingshell@ferrarodomenico.com --quiet
gnome-extensions uninstall openbar@neuromorph --quiet
gnome-extensions uninstall appindicatorsupport@rgcjonas.gmail.com --quiet
gnome-extensions uninstall hidetopbarmathieu.bidon.ca.v123.shell-extension.zip --quiet
echo -e ''
sleep 1

echo -e 'Restoring Gnome default'
rm -rf ~/.icons
rm ~/.config/dconf/user
rm ~/.config/autostart/ulauncher.desktop
rm -r ~/.config/ulauncher
sudo rm -r /usr/local/go
sudo rm -rf /usr/local/zig
echo -e ''
sleep 1

echo -e 'Anu uninstallation completed'
echo -e ''
sleep 2

gnome-session-quit --force