{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.ghosttyTerminal;
in
{
  options.custom.system.ghosttyTerminal = {
    enable = mkEnableOption "Ghostty as default terminal with persistence";
  };

  config = mkIf cfg.enable {
    # Ensure ghostty configuration persists in workflows.conf
    system.activationScripts.ghosttyWorkflow = ''
      # Ensure workflows.conf exists and contains ghostty configuration
      WORKFLOWS_CONF="/home/a/.config/hypr/workflows.conf"
      
      if [ -f "$WORKFLOWS_CONF" ]; then
        # Check if ghostty is already configured
        if ! grep -q "TERMINAL = ghostty" "$WORKFLOWS_CONF"; then
          echo "" >> "$WORKFLOWS_CONF"
          echo "# Override terminal to use ghostty (managed by NixOS)" >> "$WORKFLOWS_CONF"
          echo "\$TERMINAL = ghostty" >> "$WORKFLOWS_CONF"
          echo "" >> "$WORKFLOWS_CONF"
          echo "# Override terminal keybindings" >> "$WORKFLOWS_CONF"
          echo "unbind = SUPER, T" >> "$WORKFLOWS_CONF"
          echo "unbind = SUPER ALT, T" >> "$WORKFLOWS_CONF"
          echo "bindd = SUPER, T, [Launcher|Apps] terminal emulator, exec, ghostty" >> "$WORKFLOWS_CONF"
          echo "bindd = SUPER ALT, T, [Launcher|Apps] dropdown terminal, exec, [float; move 20% 5%; size 60% 60%] ghostty" >> "$WORKFLOWS_CONF"
        fi
      fi
    '';
  };
}
