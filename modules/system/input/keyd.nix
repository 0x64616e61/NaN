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
              
              # Space bar tap dance: tap for space, hold 150ms for nav layer
              space = "overloadt2(nav, space, 150)";
            };
            
            # Navigation layer - activated by holding space
            "nav:M" = {
              # Keys 1-0 mapped to most useful Hyprland shortcuts
              "1" = "macro(meta+t)";        # Terminal
              "2" = "macro(meta+a)";        # App Launcher
              "3" = "macro(meta+v)";        # Clipboard
              "4" = "macro(meta+p)";        # Screenshot
              "5" = "macro(meta+q)";        # Close Window
              "6" = "macro(meta+w)";        # Toggle Floating
              "7" = "macro(meta+l)";        # Lock Screen
              "8" = "macro(meta+e)";        # File Explorer
              "9" = "macro(meta+tab)";      # Window Switcher
              "0" = "macro(meta+b)";        # Browser
              
              # vim-like navigation
              h = "left";
              j = "down";
              k = "up";
              l = "right";
              
              # Window focus navigation (Super + arrows)
              w = "macro(meta+up)";         # Focus up
              a = "macro(meta+left)";       # Focus left
              s = "macro(meta+down)";       # Focus down
              d = "macro(meta+right)";      # Focus right
              
              # Workspace navigation
              q = "macro(meta+control+left)";   # Previous workspace
              e = "macro(meta+control+right)";  # Next workspace
              
              # Volume controls
              minus = "macro(f11)";         # Volume down
              equal = "macro(f12)";         # Volume up
              backspace = "macro(f10)";     # Mute
              
              # Escape to exit layer early
              esc = "esc";
            };
          };
          
          # Additional config for complex macros
          extraConfig = ''
            # Quick text snippets in nav layer
            [nav:M]
            m = macro(mini@nix)           # Your email
            t = macro(Thanks!)            # Common phrase
            g = macro(git status)         # Common git command
            
            # Display what each number does (for reference)
            # 1 = Terminal (Super+T)
            # 2 = App Launcher (Super+A)
            # 3 = Clipboard (Super+V)
            # 4 = Screenshot (Super+P)
            # 5 = Close Window (Super+Q)
            # 6 = Toggle Floating (Super+W)
            # 7 = Lock Screen (Super+L)
            # 8 = File Explorer (Super+E)
            # 9 = Window Switcher (Super+Tab)
            # 0 = Browser (Super+B)
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