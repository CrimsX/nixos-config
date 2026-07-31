sudo nix-collect-garbage --delete-older-than 30d
sudo nixos-rebuild boot --upgrade --flake .#L7490
flatpak update -y
