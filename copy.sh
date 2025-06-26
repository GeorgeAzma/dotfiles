#!/bin/bash
set -e
cd "$(dirname "$0")" 

pacman -Qqe > pkglist.txt
pacman -Qqm > aurlist.txt

mkdir -p .config
mkdir -p .local/share/nwg-look
mkdir -p usr/local/bin
mkdir -p .local/bin

command -v rsync >/dev/null 2>&1 || { echo "rsync not found, installing..."; sudo pacman -S --noconfirm rsync; }
rsync -rlptD --exclude={'google-chrome','Code','Code - OSS','obsidian','GIMP','mozc','spotify'} ~/.config/ .config/
rsync -rlptD ~/.local/share/nwg-look/ .local/share/nwg-look/
rsync -rlptD ~/.local/bin/ .local/bin/
rsync -rlptD ~/.bashrc .bashrc
sudo rsync -a /usr/local/bin/ usr/local/bin/

echo "copied $(du -sh . | cut -f1)"