{ lib, ... }:
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
      swaylock
      hyprlock
      alacritty
      kitty
      ghostty
      rofi
      wofi
      anyrun
      fuzzel
      xfce.thunar
      xfce.thunar-volman
      xfce.thunar-archive-plugin
      xfce.thunar-media-tags-plugin
      yazi
      nautilus
      nemo
      kdePackages.dolphin
      swaybg
      mpvpaper
      hyprpaper
      swww
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
      dunst
      swaynotificationcenter
      mako
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
      catppuccin-gtk
      catppuccin-kvantum
      papirus-icon-theme
      syncthing
      zathura
      pipes
      wl-clipboard
      foot
      mpv
      vlc
      anki
      qbittorrent
      #aseprite
      zed-editor
      librewolf
      ani-cli
      lsfg-vk
      lsfg-vk-ui
      graphite
      pixieditor
      stasis
      ardour
      pinta
      lmms
      kdePackages.kolourpaint
      zoxide
      bat
      eza
      helix
    ];
  };
}
