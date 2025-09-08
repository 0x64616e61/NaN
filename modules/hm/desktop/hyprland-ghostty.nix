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
    # Override the keybindings directly with higher priority
    wayland.windowManager.hyprland.extraConfig = mkAfter ''
      # Unbind the existing terminal keybindings
      unbind = SUPER, T
      unbind = SUPER ALT, T
      
      # Bind new keybindings to use Ghostty
      bindd = SUPER, T, [Launcher|Apps] terminal emulator, exec, ghostty
      bindd = SUPER ALT, T, [Launcher|Apps] dropdown terminal, exec, [float; move 20% 5%; size 60% 60%] ghostty
    '';
  };
}
