{
  description = "
    My NixOS Flake
  ";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nipkgs-stable.url = "nixpkgs/nixos-25.05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
      inputs.nispkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/hosts/L7490/default.nix
        ./modules/hosts/L7490/configuration.nix
        ./modules/hosts/L7490/hardware.nix
	./modules/hosts/desktop/default.nix
	./modules/hosts/desktop/configuration.nix
        ./modules/hosts/desktop/hardware.nix
        ./modules/features/core.nix
        ./modules/features/flatpak.nix
        ./modules/features/users.nix
        ./modules/features/hyprland.nix
        ./modules/features/mullvad.nix
        ./modules/features/niri.nix
        ./modules/features/steam.nix
        ./modules/features/stylix.nix
        ./modules/features/virt-manager.nix
        {
	/*
          flake.nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
            modules = [
              self.nixosModules.desktop-hardware
              (import ./hosts/desktop/configuration.nix { inherit inputs self; })
            ];
          };
	  */
        }
        {
          flake.nixosConfigurations.exampleIso = inputs.nixpkgs.lib.nixosSystem {
            modules = [
              ./hosts/isoimage/configuration.nix
            ];
          };
        }
      ];
    };
}
