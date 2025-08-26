#!/bin/bash
set -e
cd "$(dirname "$0")" 
pacman -Qqe | grep -v -E '^(krita|anki-bin|fio|jdk17-openjdk|android-studio|yarn|minecraft-launcher|gamescope)$' > pkglist.txt
pacman -Qqm | grep -v -E '^(krita|anki-bin|anki-bin-debug|android-studio|minecraft-launcher)$' > aurlist.txt

mkdir -p .config
mkdir -p .local/share/nwg-look
mkdir -p .local/bin

mkdir -p usr/local/bin
mkdir -p etc/systemd

command -v rsync >/dev/null 2>&1 || { echo "rsync not found, installing..."; sudo pacman -S --noconfirm rsync; }

# recursively copy symlinks, permissions, modification times, devices/special files
rsync -rlptD --delete --exclude={'google-chrome','Code','Code - OSS','obsidian','GIMP','mozc','spotify'} ~/.config/ .config/
rsync -rlptD --delete ~/.local/share/nwg-look/ .local/share/nwg-look/
rsync -rlptD --delete ~/.local/bin/ .local/bin/

sudo rsync -a --delete /usr/local/bin/ usr/local/bin/
sudo rsync -a --delete /etc/systemd/ etc/systemd/

cp ~/.bashrc .

sudo cp /etc/fstab etc/fstab

echo "copied $(du -sh . | cut -f1)"