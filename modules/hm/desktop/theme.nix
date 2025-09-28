{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.theme;
in
{
  options.custom.hm.desktop.theme = {
    catppuccinMochaTeal = mkEnableOption "Catppuccin Mocha theme with teal accent";
  };

  config = mkIf cfg.catppuccinMochaTeal {
    # Override Hyprland theme colors with Catppuccin Mocha Teal
    wayland.windowManager.hyprland.settings = {
      general = {
        "col.active_border" = "rgba(94e2d5ff) rgba(89dcebff) 45deg";
        "col.inactive_border" = "rgba(313244cc) rgba(45475acc) 45deg";
      };
      
      group = {
        "col.border.active" = "rgba(94e2d5ff) rgba(89dcebff) 45deg";
        "col.border.inactive" = "rgba(313244cc) rgba(45475acc) 45deg";
        "col.border.locked_active" = "rgba(94e2d5ff) rgba(89dcebff) 45deg";
        "col.border.locked_inactive" = "rgba(313244cc) rgba(45475acc) 45deg";
      };
    };
  };
}