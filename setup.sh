# Manual setup:
# - install arch linux
# - install yay
# - copy over everything to ~/ 

sudo pacman -S --needed - < pkglist.txt
yay -S --needed - < aurlist.txt
sudo systemctl enable --now pipewire pipewire-pulse wireplumber NetworkManager bluetooth sddm