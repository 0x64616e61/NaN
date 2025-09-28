{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.dmenuLauncher;
in
{
  options.custom.hm.desktop.dmenuLauncher = {
    enable = mkEnableOption "dmenu application launcher";
    
    keybind = mkOption {
      type = types.str;
      default = "SUPER, SPACE";
      description = "Keybind to launch dmenu";
    };

    fontSize = mkOption {
      type = types.int;
      default = 10;
      description = "Font size for dmenu";
    };

    height = mkOption {
      type = types.int;
      default = 25;
      description = "Height of dmenu bar";
    };

    colors = {
      background = mkOption {
        type = types.str;
        default = "#000000";
        description = "Background color";
      };
      
      foreground = mkOption {
        type = types.str;
        default = "#00ff00";
        description = "Foreground text color";
      };
      
      selectedBackground = mkOption {
        type = types.str;
        default = "#00ff00";
        description = "Selected item background color";
      };
      
      selectedForeground = mkOption {
        type = types.str;
        default = "#000000";
        description = "Selected item text color";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install dmenu-wayland
    home.packages = with pkgs; [
      dmenu-wayland
    ];

    # Add Hyprland keybinding for dmenu
    wayland.windowManager.hyprland.settings = {
      bind = [
        "${cfg.keybind}, exec, ${pkgs.dmenu-wayland}/bin/dmenu-wl_run -b -p 'Run: ' -fn 'monospace:size=${toString cfg.fontSize}' -nb '${cfg.colors.background}' -nf '${cfg.colors.foreground}' -sb '${cfg.colors.selectedBackground}' -sf '${cfg.colors.selectedForeground}' -h ${toString cfg.height}"
      ];
    };

    # Create a desktop entry for Spotify to ensure it's discoverable
    xdg.desktopEntries = {
      spotify = {
        name = "Spotify";
        genericName = "Music Player";
        exec = "${pkgs.spotify}/bin/spotify %U";
        terminal = false;
        icon = "spotify-client";
        type = "Application";
        categories = [ "Audio" "Music" "Player" "AudioVideo" ];
        mimeType = [ "x-scheme-handler/spotify" ];
      };
    };
  };
}