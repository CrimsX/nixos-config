{
  description = "
    My NixOS Flake
  ";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

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
    nixpkgs,
    home-manager,
    ...
    } @ inputs:
    let
    system = "x86_64-linux";
    user = "crimsx";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    in {
      nixosConfigurations = {
        L7490 = nixpkgs.lib.nixosSystem {
	  modules = [
	    ./hosts/L7490
	    stylix.nixosModules.stylix
	    ./configuration.nix
	    #./hardware-configuration.nix
	    ({ pkgs, ... }: {
	      programs.nvim.defaultEditor = true;
	    })
	    home-manager.nixosModules.home-manager {
	      home-manager = {
	        useGlobalPkgs = true;
	        useUserPackages = true;
	        users.crimsx = import ./home.nix;
	        backupFileExtension = "backup";
	      };
	      /*
	      home-manager.users.crimsx = {
	        programs.fastfetch.enable = true;
	      };
	      */
	    }
	    stylix.nixosModules.stylix
	  ];
	  specialArgs = {
	    inherit inputs system user;
	    hostname = "L7490";
	  };
	};
	forAllSystems = f: lib.genAttrs supportedSystems (system: f system);
	# forAllSystems = nixpkgs.libgenAttrs systems;
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
	};
      };
    };
  };
};
