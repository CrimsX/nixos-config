{ inputs, self, ... }:
{
  flake.nixosConfigurations.desktop =
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.desktop-configuration
      ];
    };
}
