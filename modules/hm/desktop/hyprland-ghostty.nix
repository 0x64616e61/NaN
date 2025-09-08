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
    # Force workflows.conf to be a symlink managed by home-manager
    home.file.".config/hypr/workflows.conf" = {
      force = true;  # Force overwrite even if file exists
      text = ''
        # // █▀▄ █▀▀ █▀▀ ▄▀█ █░█ █░░ ▀█▀
        # // █▄▀ ██▄ █▀░ █▀█ █▄█ █▄▄ ░█░
        
        $WORKFLOW_ICON=
        $WORKFLOW_DESCRIPTION = Unset workflow configuration
        
        # Force landscape orientation on startup for GPD Pocket 3
        exec-once = sleep 1 && hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.500000,transform,3
        
        # Override terminal keybindings to use Ghostty instead of Kitty
        unbind = SUPER, T
        unbind = SUPER ALT, T
        bind = SUPER, T, exec, ghostty
        bind = SUPER ALT, T, exec, [float; move 20% 5%; size 60% 60%] ghostty
      '';
    };
  };
}
