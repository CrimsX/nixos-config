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
    lib = nixpkgs.lib;
    user = "crimsx";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    in {
      nixosConfigurations = {
        /*
	host = lib.nixosSystem {
	  inherit system;
	  modules = [
	    ./hosts/$()/configuration.nix
	  ];
	  specialArgs = { inherit inputs username; };
	};
	*/

        L7490 = nixpkgs.lib.nixosSystem {
	  modules = [
	    #./hosts/L7490
	    ./configuration.nix
	    #./hardware-configuration.nix
	    ({ pkgs, ... }: {
	      programs.neovim.defaultEditor = true;
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
	    inputs.stylix.nixosModules.stylix
	    /*
	    waybar = import ./nixos/modules/waybar.nix;
	    default = { ... }: {
	      imports = [
	        #home-manager.nixosModules.home-manager
		#self.nixosModules.
	      ];
	    };
	    */
	  ];
	  specialArgs = {
	    inherit inputs system user;
	    hostname = "L7490";
	  };
	};
	forAllSystems = nixpkgs.libgenAttrs system;

	/*
	homeConfigurations = {
	  "${user}@..." = home-manager.libhomeManagerConfiguration {
	    inherit pkgs;
	    extraSpecialArgs = { inherit inputs username; };
	    modules = [
	      ./
	    ];
	};
	*/
      };
    };
  }
