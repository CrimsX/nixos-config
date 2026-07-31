#!/usr/bin/env bash
set -euo pipefail

nix flake update
sudo nixos-rebuild boot --flake .#L7490
flatpak update -y
sudo nix-collect-garbage --delete-older-than 30d
