{ ... }:
{
  flake.nixosModules.virt-manager = { ... }: {
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = [ "crimsx" ];
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
