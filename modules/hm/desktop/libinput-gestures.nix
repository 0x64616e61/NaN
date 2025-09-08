{ config, pkgs, lib, ... }:

let
  cfg = config.custom.hm.desktop.libinputGestures;
in
{
  options.custom.hm.desktop.libinputGestures = {
    enable = lib.mkEnableOption "libinput gestures for touchscreen scrolling in terminals";
  };

  config = lib.mkIf cfg.enable {
    # Install libinput-gestures
    home.packages = with pkgs; [
      libinput-gestures
    ];
    
    # Create libinput-gestures configuration
    home.file.".config/libinput-gestures.conf".text = ''
      # Gestures for terminal scrolling (works with both Kitty and Ghostty)
      # One-finger swipe up/down for page scrolling (touchscreen)
      gesture swipe up 1 xdotool key --window $(xdotool search --class ghostty | head -1 || xdotool search --class kitty | head -1) Page_Up
      gesture swipe down 1 xdotool key --window $(xdotool search --class ghostty | head -1 || xdotool search --class kitty | head -1) Page_Down
      
      # Two-finger swipe up/down for line scrolling
      gesture swipe up 2 xdotool key --window $(xdotool search --class ghostty | head -1 || xdotool search --class kitty | head -1) alt+Up
      gesture swipe down 2 xdotool key --window $(xdotool search --class ghostty | head -1 || xdotool search --class kitty | head -1) alt+Down
      
      # Three-finger swipe for page scrolling  
      gesture swipe up 3 xdotool key --window $(xdotool search --class ghostty | head -1 || xdotool search --class kitty | head -1) alt+Page_Up
      gesture swipe down 3 xdotool key --window $(xdotool search --class ghostty | head -1 || xdotool search --class kitty | head -1) alt+Page_Down
      
      # Pinch gestures for font size control
      gesture pinch in xdotool key ctrl+shift+minus
      gesture pinch out xdotool key ctrl+shift+equal
    '';
    
    # Enable libinput-gestures service
    systemd.user.services.libinput-gestures = {
      Unit = {
        Description = "Libinput Gestures";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures";
        Restart = "on-failure";
        RestartSec = "1";
      };
      
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}