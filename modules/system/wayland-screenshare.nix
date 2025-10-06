{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.waylandScreenshare;
  
  # Create a modified Slack package with Wayland flags
  slackWithWayland = pkgs.writeShellScriptBin "slack-wayland" ''
    exec ${pkgs.slack}/bin/slack \
      --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
      --ozone-platform=wayland \
      --enable-webrtc-pipewire-capturer \
      --disable-gpu-memory-buffer-video-frames \
      "$@"
  '';
  
  # Create desktop entry for Slack with Wayland
  slackDesktopEntry = pkgs.makeDesktopItem {
    name = "slack-wayland";
    exec = "${slackWithWayland}/bin/slack-wayland %U";
    icon = "slack";
    desktopName = "Slack (Wayland)";
    comment = "Slack with Wayland screen sharing support";
    categories = [ "Network" "InstantMessaging" ];
    mimeTypes = [ "x-scheme-handler/slack" ];
  };
in
{
  options.custom.system.waylandScreenshare = {
    enable = mkEnableOption "Wayland screen sharing support for Electron apps";
  };

  config = mkIf cfg.enable {
    # Ensure xdg-desktop-portal-hyprland is installed and configured
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        };
      };
    };

    # Enable pipewire for screen capture
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;  # Essential for screen capture
    };

    # Add Wayland-enabled wrappers and desktop entries
    environment.systemPackages = [
      pkgs.slack  # Base Slack package needed for resources
      slackWithWayland
      slackDesktopEntry
      
      # Wrapper for Teams if needed
      (pkgs.writeShellScriptBin "teams-wayland" ''
        # Check if teams exists
        if command -v teams &> /dev/null; then
          exec teams \
            --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
            --ozone-platform=wayland \
            --enable-webrtc-pipewire-capturer \
            "$@"
        else
          echo "Teams is not installed"
          exit 1
        fi
      '')
      
      # Chrome/Chromium with Wayland flags (useful for web-based Teams)
      (pkgs.writeShellScriptBin "chromium-wayland" ''
        exec ${pkgs.chromium}/bin/chromium \
          --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
          --ozone-platform=wayland \
          --enable-webrtc-pipewire-capturer \
          "$@"
      '')
    ];
  };
}