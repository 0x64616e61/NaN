{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.hyprlandGhostty;
in
{
  options.custom.hm.desktop.hyprlandGhostty = {
    enable = mkEnableOption "Hyprland keybinding override for Ghostty";
  };

  config = mkIf cfg.enable {
    # Directly override terminal keybindings in Hyprland settings
    wayland.windowManager.hyprland.settings = {
      # Unbind existing terminal keybindings
      unbind = [
        "SUPER, T"
        "SUPER ALT, T"
      ];
      
      # Bind new keybindings to use Ghostty instead of Kitty
      bind = [
        "SUPER, T, exec, ghostty"
        "SUPER ALT, T, exec, [float; move 20% 5%; size 60% 60%] ghostty"
      ];
    };
  };
}
