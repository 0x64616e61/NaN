{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.gestures;
in
{
  options.custom.hm.gestures = {
    enable = mkEnableOption "Touchscreen gesture controls";
  };

  config = mkIf cfg.enable {
    # libinput-gestures for touchscreen
    home.packages = with pkgs; [
      libinput-gestures
      ydotool
      wtype
    ];

    # Gesture configuration
    home.file.".config/libinput-gestures.conf".text = ''
      # Touchscreen gestures for GPD Pocket 3

      # 3-finger swipe gestures (workspace switching)
      gesture swipe up 3 ydotool key 125:1 49:1 49:0 125:0
      gesture swipe down 3 ydotool key 125:1 50:1 50:0 125:0
      gesture swipe left 3 ydotool key 125:1 10:1 10:0 125:0
      gesture swipe right 3 ydotool key 125:1 11:1 11:0 125:0

      # 4-finger gestures (application control)
      gesture swipe up 4 ydotool key 56:1 36:1 36:0 56:0
      gesture swipe down 4 ydotool key 56:1 24:1 24:0 56:0

      # Pinch gestures
      gesture pinch in 2 ydotool key 29:1 12:1 12:0 29:0
      gesture pinch out 2 ydotool key 29:1 13:1 13:0 29:0
    '';

    # Autostart libinput-gestures
    systemd.user.services.libinput-gestures = {
      Unit = {
        Description = "Touchscreen gesture recognition";
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # ydotool daemon for gesture actions
    systemd.user.services.ydotoold = {
      Unit = {
        Description = "ydotool daemon for input automation";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.ydotool}/bin/ydotoold";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
