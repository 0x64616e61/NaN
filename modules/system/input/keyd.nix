{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.input.keyd;
in
{
  options.custom.system.input.keyd = {
    enable = mkEnableOption "keyd keyboard remapping daemon";
  };

  config = mkIf cfg.enable {
    # Enable keyd service with proper configuration structure
    services.keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ];  # Match all keyboards
          settings = {
            main = {
              # Make Capslock act as Escape on tap, Control on hold
              capslock = "overload(control, esc)";
              
              # Right Alt as Compose key for special characters
              rightalt = "compose";
              
              # Example: Make Tab act as Tab on tap, navigation layer on hold
              # tab = "overload(nav, tab)";
            };
            
            # Example navigation layer (uncomment to use)
            # "nav:C" = {
            #   h = "left";
            #   j = "down";
            #   k = "up";
            #   l = "right";
            #   u = "pageup";
            #   d = "pagedown";
            #   "0" = "home";
            #   "4" = "end";  # $ doesn't work well in Nix attrsets
            # };
          };
          
          # Additional config can be added with extraConfig
          extraConfig = ''
            # Example macro: Alt+M types your email
            # [main]
            # alt.m = macro(myemail@example.com)
            
            # You can add more complex configurations here
            # that don't fit well in the settings structure
          '';
        };
      };
    };
    
    # Ensure keyd package is installed
    environment.systemPackages = with pkgs; [
      keyd
    ];
  };
}