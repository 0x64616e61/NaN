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
    # Override hyde.conf to set ghostty as default terminal
    home.activation.hydeGhosttyConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      HYDE_CONF="$HOME/.config/hypr/hyde.conf"
      
      if [ -f "$HYDE_CONF" ]; then
        # Uncomment and set TERMINAL to ghostty
        ${pkgs.gnused}/bin/sed -i 's/# \$TERMINAL = kitty/\$TERMINAL = ghostty/' "$HYDE_CONF"
        
        # If that didn't work (already uncommented), replace kitty with ghostty
        ${pkgs.gnused}/bin/sed -i 's/\$TERMINAL = kitty/\$TERMINAL = ghostty/' "$HYDE_CONF"
        
        echo "HyDE configured to use ghostty as default terminal"
      fi
    '';
  };
}
