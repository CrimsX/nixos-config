{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  /*
  hardware.disko.enable = true;
  programs.nix-ld.enable = true;
  common.services.appimage.enable = true;
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [
  ];
  */

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "L7490"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  services.displayManager.ly.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.crimsx = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      fastfetch
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    waybar
    fuzzel
    
    ripgrep
    fd
    lazygit
    fzf

    btop
    tmux
    cava

    # Screen locker
    swaylock
    hyprlock

    # Terminal
    alacritty
    kitty
    ghostty

    # App launcher
    rofi
    wofi
    anyrun

    # File manager
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    xfce.thunar-media-tags-plugin
    yazi
    nautilus
    nemo

    # Wallpaper
    swaybg
    mpvpaper
    hyprpaper
    #yin
    swww

    # Idle daemon
    swayidle
    hypridle

    lightdm
    tlp
    fish
    starship
    hyprcursor
    hyprshot
    #zen

    # Notifications
    dunst
    swaynotificationcenter
  ];

  programs.hyprland.enable = true;
  programs.niri.enable = true;

  # Set default editor
  environment.variables.EDITOR = "nvim";

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  system.stateVersion = "25.05"; # Did you read the comment? Yes :D
}
