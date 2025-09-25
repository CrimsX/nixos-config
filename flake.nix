{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    niri.url = "github:YaLTeR/niri";
    niri-stable.url = "github:YaLTeR/niri/v25.08"

    xwayland-satellite.url = "github:Supreeeme/xwayland-satellite";
    xwayland-satellite-stable.url = "github:Supreeeme/xwayland-satellite/v0.7";

    niri.flake = false;
    niri-stable.flake = false;

    xwayland-satellite.flake = false;
    xwayland-satellite-stable.flake = false;

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #neovim = {
    #  url =
    #  flake = false;
    #};

    #zen-browser = {
    #  url =
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    #thunderbird-catppuccin = {
    #  url =
    #  flake = false;
    #};
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    stylix,
    ...
    } @ inputs:
    let
      inherit (nixpkgs) lib;
      supportedSystems = [
        "x86_64-linux"
	"aarch64-linux"
      ];
      forAllSystems = f: lib.genAttrs supportedSystems (system: f system);
    in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.$(system}.crimsx);

    nixosModules = {
      waybar = import ./nixos/modules/waybar.nix;
      default = { ... }: {
        imports = [
	  home-manager.nixosModules.ome-manager
	  self.nixosModules.
	];
      };
    };

    {
    /*
      nixosConfigurations = {
        test = nixpkgs.lib.nixosSystem {
	  system = "x86_64-linux";
	  specialArgs = { inherit inputs; };
	  modules = [
	    ./hosts/workstation
	    stylix.nixosModules.stylix
	  ];
	};
      };
      */
      nixosConfigurations.L7490 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Import the previous configuration.nix we used,
	  # so the old configuration file still takes effect
	  ./configuration.nix
	  
	  home-manager.nixosModules.home-manager
	  {
	    home-manager = {
	      useGlobalPkgs = true;
	      useUserPackages = true;
	      users.crimsx = import ./home.nix;
	      backupFileExtension = "backup";
	    };
	    # home-manager.users.crimsx = {
	    #   programs.fastfetch.enable = true;
	    # };
	  }
	  stylix.nixosModules.stylix
        ];
      };
    };
}
