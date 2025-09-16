{
  description = "My NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = 
    { self, nixpkgs, home-manager, stylix, ... }:
    {
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
