{ ... }:
{
  flake.nixosModules.niri-stylix = { lib, config, ... }:
  let
    inherit (lib) mkIf;
  in
  {
    options.stylix.targets.niri.enable = config.lib.stylix.mkEnableTarget "niri" true;

    config = mkIf (config.stylix.enable && config.stylix.targets.niri.enable) {
      home-manager.users.crimsx.xdg.configFile."niri/config.kdl".text = let
        colors = config.lib.stylix.colors.withHashtag;
      in
        ''
          layout {
              focus-ring {
                  enable false
              }
              border {
                  enable true
                  active {
                      color "${colors.base0D}"
                  }
                  inactive {
                      color "${colors.base03}"
                  }
              }
          }
        ''
        + (if config.stylix.cursor != null then ''
            cursor {
                size ${toString config.stylix.cursor.size}
                theme "${config.stylix.cursor.name}"
            }
          '' else "");
    };
  };
}
