{ ... }:
{
  flake.nixosModules.L7490-hardware =
    { config, lib, pkgs, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/e989ab0d-ff3c-46f5-9eec-3833848837f2";
        fsType = "btrfs";
        options = [ "subvol=@" "compress=zstd" ];
      };

      boot.initrd.luks.devices."luks-f490b786-4a4b-4db6-a03d-64b660081ff4".device = "/dev/disk/by-uuid/f490b786-4a4b-4db6-a03d-64b660081ff4";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/2A93-1165";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

      swapDevices = [ ];

      networking.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
