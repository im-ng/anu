#!/bin/bash

echo -e 'Restoring default Gnome session'
echo -e ''

echo -e 'Removing dependency softwares'
sudo apt autoremove wget -y
sudo apt autoremove chrome-gnome-shell -y
sudo apt autoremove gnome-browser-connector -y
sudo apt autoremove ulauncher -y
echo -e ''
sleep 1

echo -e 'Removing extensions'
gnome-extensions uninstall Vitals@CoreCoding.com --quiet
gnome-extensions uninstall tilingshell@ferrarodomenico.com --quiet
gnome-extensions uninstall openbar@neuromorph --quiet
gnome-extensions uninstall appindicatorsupport@rgcjonas.gmail.com --quiet
echo -e ''
sleep 1

echo -e 'Restoring Gnome default'
rm ~/.config/dconf/user
rm ~/.config/autostart/ulauncher.desktop
rm -r ~/.config/ulauncher
echo -e ''
sleep 1

echo -e 'Anubar uninstallation completed'
echo -e ''
sleep 2

gnome-session-quit --force