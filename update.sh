sudo nix-collect-garbage --delete-older-than 30d
suod nixos-rebuild boot --upgrade
flatpak update -y
