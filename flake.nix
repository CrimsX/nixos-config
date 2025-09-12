{
  description = "A simple NixOS flake from scratch";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
	# so the old configuration file still takes effect
	./configuration.nix
	# home-manager.nixosModules.home-manager
	# {
	#  home-manager = {
	#    useGlobalPkgs = true;
	#    useUserPackages = true;
	#    users.crimsx = import ./home.nix;
	#    backupFileExtension = "backup";
	#  };
	# }
      ];
    };
  };
}
