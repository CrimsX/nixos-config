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
}
