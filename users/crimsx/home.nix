{ config, pkgs, ... }:
{
  home.username = "crimsx";
  home.homeDirectory = "/home/crimsx";
  programs.git.enable = true;
  home.stateVersion = "25.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos, btw";
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {
        "extensions.activeThemeID" = "{47f5c9df-1d03-5424-ae9e-0613b69a9d2f}";
        "extensions.autoDisableScopes" = 0;
      };
      extensions = [
        (pkgs.runCommand "catppuccin-thunderbird-mocha" { } ''
          mkdir -p $out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}
          cp ${pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/catppuccin/thunderbird/main/themes/mocha/mocha-mauve.xpi";
            sha256 = "02a72b10ecc121d6dac717ebca08784aeef6e2b7f177a956e42fa1604ee49f40";
          }} $out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/{47f5c9df-1d03-5424-ae9e-0613b69a9d2f}.xpi
        '')
      ];
    };
  };
}
