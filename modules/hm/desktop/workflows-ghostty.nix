{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.workflowsGhostty;
in
{
  options.custom.hm.desktop.workflowsGhostty = {
    enable = mkEnableOption "Ghostty terminal in workflows.conf";
  };

  config = mkIf cfg.enable {
    # Create workflows.conf for Ghostty
    home.file.".config/hypr/workflows.conf" = {
      text = ''
        # // █▀▄ █▀▀ █▀▀ ▄▀█ █░█ █░░ ▀█▀
        # // █▄▀ ██▄ █▀░ █▀█ █▄█ █▄▄ ░█░

        $WORKFLOW_ICON=
        $WORKFLOW_DESCRIPTION = Ghostty terminal configuration

        # Force landscape orientation on startup for GPD Pocket 3
        exec-once = sleep 1 && hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.500000,transform,3

        # Override terminal to use ghostty
        $TERMINAL = ghostty

        # Override terminal keybindings
        unbind = SUPER, T
        unbind = SUPER ALT, T
        bindd = SUPER, T, [Launcher|Apps] terminal emulator, exec, ghostty
        bindd = SUPER ALT, T, [Launcher|Apps] dropdown terminal, exec, [float; move 20% 5%; size 60% 60%] ghostty
      '';
      force = true;  # Force overwrite the managed file
    };
  };
}
