{ ... }:
{
  flake.nixosModules.users = { pkgs, ... }: {
    users.users.crimsx = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        fastfetch
      ];
    };
  };
}
