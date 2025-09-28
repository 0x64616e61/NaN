{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.waybarPureNix;

  # Ultra-minimal OLED-optimized waybar configuration
  waybarConfig = {
    layer = "top";
    position = "top";
    height = 20;
    exclusive = true;
    passthrough = false;
    gtk-layer-shell = true;

    modules-left = [
      "hyprland/workspaces"
    ];

    modules-center = [
      "custom/launcher"
    ];

    modules-right = [
      "battery"
      "network"
      "clock"
    ];

    # Ultra-minimal workspaces - just numbers
    "hyprland/workspaces" = {
      disable-scroll = false;
      all-outputs = true;
      on-click = "activate";
      format = "{name}";
      format-icons = {};
      persistent-workspaces = {
        "*" = [ 1 2 3 4 5 ];
      };
    };

    # Dmenu launcher module
    "custom/launcher" = {
      format = "[ run ]";
      on-click = "${pkgs.rofi-wayland}/bin/rofi -show drun";
      tooltip = false;
    };

    # Ultra-compact battery display
    battery = {
      format = "B:{capacity}%";
      states = {
        warning = 30;
        critical = 15;
      };
      tooltip = false;
    };

    # Ultra-compact network display
    network = {
      format-wifi = "N:Y";
      format-ethernet = "N:Y";
      format-disconnected = "N:N";
      tooltip = false;
    };

    # Ultra-compact clock display
    clock = {
      format = "{:%H:%M}";
      tooltip = false;
    };
  };

  # Ultra-minimal OLED-optimized CSS
  waybarStyle = ''
    /* Ultra-minimal OLED-optimized waybar */
    * {
      font-family: monospace;
      font-size: 10px;
      font-weight: normal;
      min-height: 0;
      padding: 0;
      margin: 0;
      border: none;
      border-radius: 0;
      transition: none;
      animation: none;
    }

    window#waybar {
      background: #000000;
      color: #FFFFFF;
      border: none;
    }

    /* Workspaces - ultra minimal, just numbers */
    #workspaces {
      background: transparent;
      padding: 0;
      margin: 0;
    }

    #workspaces button {
      color: #FFFFFF;
      background: transparent;
      padding: 0 4px;
      margin: 0;
      border: none;
      min-width: 0;
      min-height: 20px;
      transition: none;
    }

    #workspaces button.active {
      color: #000000;
      background: #FFFFFF;
      transition: none;
    }

    /* Center launcher */
    #custom-launcher {
      background: transparent;
      color: #FFFFFF;
      padding: 0 8px;
      margin: 0;
      border: none;
    }

    #custom-launcher:hover {
      background: #FFFFFF;
      color: #000000;
    }

    /* Right modules - ultra compact */
    #battery,
    #network,
    #clock {
      background: transparent;
      color: #FFFFFF;
      padding: 0 4px;
      margin: 0;
      border: none;
    }
  '';

in
{
  options.custom.hm.desktop.waybarPureNix = {
    enable = mkEnableOption "minimal DWM-style waybar configuration";

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically start waybar with Hyprland";
    };
  };

  config = mkIf cfg.enable {
    # Install waybar and rofi packages
    home.packages = with pkgs; [
      waybar
      rofi-wayland
    ];

    # Waybar configuration
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = waybarConfig;
      };
      style = waybarStyle;
    };

    # Add keybind for dmenu launcher
    wayland.windowManager.hyprland.settings = mkIf cfg.autoStart {
      exec-once = [
        "${pkgs.waybar}/bin/waybar"
      ];
      bind = [
        "SUPER, D, exec, ${pkgs.rofi-wayland}/bin/rofi -show drun"
      ];
    };
  };
}