{ inputs, self, ... }:
{
  flake.nixosConfigurations.L7490 =
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.L7490-configuration
      ];
    };
}
