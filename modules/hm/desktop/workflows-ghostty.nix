{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.workflowsGhostty;
in
{
  options.custom.hm.desktop.workflowsGhostty = {
    enable = mkEnableOption "Ghostty terminal in workflows";
  };

  config = mkIf cfg.enable {
    # Override the default workflow to include ghostty settings
    home.file.".config/hypr/workflows/default.conf" = {
      text = ''
        # // █▀▄ █▀▀ █▀▀ ▄▀█ █░█ █░░ ▀█▀
        # // █▄▀ ██▄ █▀░ █▀█ █▄█ █▄▄ ░█░

        $WORKFLOW_ICON=
        $WORKFLOW_DESCRIPTION = Default with Ghostty terminal

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
