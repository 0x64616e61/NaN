{ config, lib, pkgs, ... }:

with lib;

{
  # Touchscreen and pen input configuration for GPD Pocket 3
  # Device: GXTP7380:00 27C6:0113 (touch + stylus)

  # LibInput configuration for touchscreen
  services.libinput = {
    enable = true;

    touchpad = {
      tapping = true;
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };

  # Environment variables for touch/pen
  environment.sessionVariables = {
    # Force Wayland touch support
    MOZ_USE_XINPUT2 = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";

    # Map touchscreen to HDMI output (HDMI-A-1)
    # This makes the GPD touchscreen control the external HDMI monitor
    WLR_LIBINPUT_NO_DEVICES = "0";
  };

  # Touchscreen utilities
  environment.systemPackages = with pkgs; [
    libinput
    libinput-gestures
    wl-clipboard
    wtype  # Wayland text input
    ydotool  # Wayland automation for gestures
  ];

  # udev rules for pen/touch access
  services.udev.extraRules = ''
    # GXTP7380 touchscreen and pen
    SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="GXTP7380:00 27C6:0113", TAG+="uaccess"
    SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="GXTP7380:00 27C6:0113 Stylus", TAG+="uaccess"

    # Add to input group
    SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="GXTP7380:00 27C6:0113*", GROUP="input", MODE="0660"
  '';

  # Pen/touch calibration persistence
  environment.etc."libinput/local-overrides.quirks".text = ''
    [GXTP7380 Touchscreen]
    MatchName=GXTP7380:00 27C6:0113
    MatchDeviceTree=*
    AttrSizeHint=267x178
    AttrTouchSizeRange=1:10
    ModelTabletModeNoSuspend=1
    # Map touchscreen to HDMI output (external monitor)
    # This makes touch events route to HDMI-A-1 instead of DSI-1
    AttrOutputName=HDMI-A-1
  '';
}
