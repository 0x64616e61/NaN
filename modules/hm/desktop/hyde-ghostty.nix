{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.hydeGhostty;
in
{
  options.custom.hm.desktop.hydeGhostty = {
    enable = mkEnableOption "Configure HyDE to use ghostty terminal";
  };

  config = mkIf cfg.enable {
    # Create a workflows override that sets ghostty as terminal
    # This avoids modifying the read-only hyde.conf
    home.file.".config/hypr/workflows.conf" = {
      text = ''
        # Override terminal to use ghostty
        $TERMINAL = ghostty
        
        # Include any other workflow customizations here
        ${lib.optionalString (builtins.pathExists "/home/a/.config/hypr/workflows.conf.base") 
          (builtins.readFile "/home/a/.config/hypr/workflows.conf.base")}
      '';
      force = true;  # Force overwrite even if file exists
    };
  };
}
