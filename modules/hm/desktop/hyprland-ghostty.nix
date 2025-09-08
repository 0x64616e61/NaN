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
    # Create an override config that will be sourced by Hyprland
    home.file.".config/hypr/conf/ghostty-override.conf".text = ''
      # Override terminal keybindings to use Ghostty instead of Kitty
      # This unbinds the existing keybindings and creates new ones
      
      unbind = SUPER, T
      unbind = SUPER ALT, T
      
      # Bind Super+T to open Ghostty
      bind = SUPER, T, exec, ghostty
      
      # Bind Super+Alt+T to open floating Ghostty
      bind = SUPER ALT, T, exec, [float; move 20% 5%; size 60% 60%] ghostty
    '';
    
    # Ensure this config is sourced by adding it to the main hyprland.conf
    wayland.windowManager.hyprland.extraConfig = mkAfter ''
      source = ~/.config/hypr/conf/ghostty-override.conf
    '';
  };
}