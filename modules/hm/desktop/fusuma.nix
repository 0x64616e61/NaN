{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.fusuma;
in
{
  options.custom.hm.desktop.fusuma = {
    enable = mkEnableOption "Fusuma touchpad gesture recognizer";
    
    threshold = {
      swipe = mkOption {
        type = types.float;
        default = 0.1;
        description = "Swipe sensitivity threshold";
      };
      
      pinch = mkOption {
        type = types.float;
        default = 0.1;
        description = "Pinch sensitivity threshold";
      };
    };
    
    interval = {
      swipe = mkOption {
        type = types.float;
        default = 0.75;
        description = "Swipe interval";
      };
      
      pinch = mkOption {
        type = types.float;
        default = 0.5;
        description = "Pinch interval";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install fusuma and required tools
    home.packages = with pkgs; [
      xdotool  # For sending key commands
      ydotool  # For Wayland support
      ruby
      wmctrl
    ];
    
    # Fusuma configuration
    home.file.".config/fusuma/config.yml".text = ''
      swipe:
        3:
          left:
            command: 'hyprctl dispatch workspace +1'
          right:
            command: 'hyprctl dispatch workspace -1'
          up:
            command: 'hyprctl dispatch fullscreen 1'
          down:
            command: 'hyprctl dispatch fullscreen 0'
        4:
          left:
            command: 'hyprctl dispatch movewindow l'
          right:
            command: 'hyprctl dispatch movewindow r'
          up:
            command: 'hyprctl dispatch killactive'
          down:
            command: 'rofi -show drun'
            
      pinch:
        2:
          in:
            command: 'hyprctl keyword misc:cursor_zoom_factor 1'
          out:
            command: 'hyprctl keyword misc:cursor_zoom_factor 2'
        3:
          in:
            command: 'hyprctl dispatch workspace m-1'
          out:
            command: 'hyprctl dispatch workspace m+1'
            
      hold:
        3:
          command: 'rofi -show window'
        4:
          command: 'hyprctl dispatch killactive'
          
      threshold:
        swipe: ${toString cfg.threshold.swipe}
        pinch: ${toString cfg.threshold.pinch}
        
      interval:
        swipe: ${toString cfg.interval.swipe}
        pinch: ${toString cfg.interval.pinch}
        
      device:
        # Will auto-detect touchpad
        
      plugin:
        inputs:
          libinput_command_input:
            enable-tap: true
            enable-dwt: true
            show-device-name: true
    '';
    
    # Install fusuma via gem
    home.activation.installFusuma = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if ! command -v fusuma >/dev/null 2>&1; then
        $DRY_RUN_CMD ${pkgs.ruby}/bin/gem install fusuma fusuma-plugin-sendkey fusuma-plugin-keypress --user-install
      fi
    '';
    
    # Create systemd user service for fusuma
    systemd.user.services.fusuma = {
      Unit = {
        Description = "Fusuma touchpad gesture daemon";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "$HOME/.local/share/gem/ruby/3.1.0/bin/fusuma";
        Restart = "on-failure";
        RestartSec = 3;
        Environment = [
          "HOME=%h"
          "PATH=$HOME/.local/share/gem/ruby/3.1.0/bin:${pkgs.ruby}/bin:${pkgs.ydotool}/bin:${pkgs.xdotool}/bin:$PATH"
          "GEM_HOME=$HOME/.local/share/gem"
        ];
      };
      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
    
  };
}