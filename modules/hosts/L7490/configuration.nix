{ inputs, self, ... }:
{
  flake.nixosModules.L7490-configuration = {
    imports = [
      self.nixosModules.L7490-hardware
      self.nixosModules.core
      self.nixosModules.users
      self.nixosModules.hyprland
      self.nixosModules.niri
      self.nixosModules.niri-stylix
      self.nixosModules.virt-manager
      inputs.home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.crimsx = import ../../../users/crimsx/home.nix;
      backupFileExtension = "backup";
    };

    programs.neovim.defaultEditor = true;

    networking.hostName = "L7490";
    system.stateVersion = "25.05";
  };
}
