{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.touchscreen;
in
{
  options.custom.hm.desktop.touchscreen = {
    enable = mkEnableOption "Touchscreen configuration";
    rotation = mkOption {
      type = types.int;
      default = 270;
      description = "Display rotation in degrees";
    };
  };

  config = mkIf cfg.enable {
    # Touchscreen packages
    home.packages = with pkgs; [
      wev
      evtest
    ];
  };
}
