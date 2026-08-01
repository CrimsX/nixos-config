{ lib, inputs, ... }:
{
  flake.nixosModules.core = { pkgs, ... }: {
    boot.loader = {
	grub.enable = lib.mkForce false;
	systemd-boot.enable = false;
	refind.enable = true;
	efi.canTouchEfiVariables = true;
	timeout = 10;
};

    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.networkmanager.enable = true;

    time.timeZone = "America/Edmonton";

    services.displayManager.ly.enable = true;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.config.allowUnfree = true;

    environment.variables.EDITOR = "nvim";

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      iosevka
    ];

    environment.systemPackages = with pkgs; [
      git
      neovim
      wget
      waybar

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
      fuzzel

      # File manager
      xfce.thunar
      xfce.thunar-volman
      xfce.thunar-archive-plugin
      xfce.thunar-media-tags-plugin
      yazi
      nautilus
      nemo
      kdePackages.dolphin

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
      grim
      slurp
      #zen

      # Notifications
      dunst
      swaynotificationcenter
      mako

      # Apps
      #discord-ptb
      vesktop
      bitwarden-desktop
      godot
      obs-studio
      obsidian

      ffmpeg
      imagemagick
      python3
      pyprland

      # Theme
      catppuccin-gtk
      catppuccin-kvantum
      # Catpuccin-cursors
      papirus-icon-theme

      syncthing
      zathura

      pipes
      wl-clipboard
      foot
      mpv
      vlc
      thunderbird
      anki
      qbittorrent


      #aseprite
      godot

      zed-editor
      librewolf
      (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default)
      ani-cli

      lsfg-vk
      lsfg-vk-ui

      graphite
      pixieditor
      winboat
      stasis
      ardour
      pinta
      lmms
      kdePackages.kolourpaint

      zoxide
      bat
      eza

      grim
      slurp
      helix

      /*
      programs.virt-manager.enable = true;
      users.groups.libirtd.members = ["crimsx"];
      virtualisation.libvirtd.enable = true;
      virutalisation.spaceUSBRedirection.enable = true;
      */
    ];
  };
}
