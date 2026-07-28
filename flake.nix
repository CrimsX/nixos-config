{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    niri = {
      url = "github:YaLTeR/niri";
      flake = false;
    };

    xwayland-satellite = {
      url = "github:Supreeeme/xwayland-satellite";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/hosts/L7490/default.nix
        ./modules/hosts/L7490/configuration.nix
        ./modules/hosts/L7490/hardware.nix
        ./modules/features/core.nix
        ./modules/features/users.nix
        ./modules/features/hyprland.nix
        ./modules/features/niri.nix
        ./modules/features/stylix.nix
        ./modules/features/virt-manager.nix
        {
          nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
            modules = [
              { config, lib, pkgs, modulesPath, ... }: {
                imports = [
                  (modulesPath + "/installer/scan/not-detected.nix")
                ];
              }
              ./hosts/desktop/configuration.nix
            ];
          };
        }
        {
          nixosConfigurations.exampleIso = inputs.nixpkgs.lib.nixosSystem {
            modules = [
              ./hosts/isoimage/configuration.nix
            ];
          };
        }
      ];
    };
}
