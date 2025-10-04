{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.waybarPureNix;

  # System-wide transparency setting (0.0 = fully transparent, 1.0 = fully opaque)
  systemOpacity = 0.85;

  # Convert opacity to hex alpha channel (00-FF)
  opacityToHex = opacity:
    let
      alpha = builtins.floor (opacity * 255);
      toHexDigit = n: builtins.elemAt ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f"] n;
      high = toHexDigit (alpha / 16);
      low = toHexDigit (builtins.bitAnd alpha 15);
    in "${high}${low}";

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
      "custom/launcher"  # dmenu launcher
    ];

    modules-right = [
      "cpu"
      "memory"
      "disk"
      "temperature"
      "backlight"
      "pulseaudio"
      "battery"
      "network"
      "tray"
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

    # Fuzzel launcher
    "custom/launcher" = {
      format = "";
      exec = "echo ''";
      on-click = "${pkgs.fuzzel}/bin/fuzzel";
      tooltip-format = "Press Windows+A to launch";
    };

    # Ultra-compact temperature display
    temperature = {
      hwmon-path = "/sys/class/thermal/thermal_zone5/temp";
      format = "T:{temperatureC}°";
      critical-threshold = 80;
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

    # CPU usage
    cpu = {
      format = "C:{usage}%";
      interval = 2;
      on-click = "ghostty -e btop";
      tooltip = true;
    };

    # Memory usage
    memory = {
      format = "M:{percentage}%";
      interval = 2;
      on-click = "ghostty -e btop";
      tooltip-format = "{used:0.1f}G/{total:0.1f}G";
    };

    # Disk usage
    disk = {
      format = "D:{percentage_used}%";
      path = "/";
      interval = 30;
      on-click = "ghostty -e ncdu /";
      tooltip-format = "{used}/{total} ({percentage_used}%)";
    };

    # Backlight control
    backlight = {
      format = "L:{percent}%";
      on-scroll-up = "brightnessctl set +5%";
      on-scroll-down = "brightnessctl set 5%-";
      tooltip-format = "Brightness: {percent}%";
    };

    # Audio control
    pulseaudio = {
      format = "V:{volume}%";
      format-muted = "V:M";
      on-click = "pavucontrol";
      on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
      on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
      tooltip-format = "{desc}";
    };

    # System tray
    tray = {
      icon-size = 16;
      spacing = 5;
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
      background: rgba(0, 0, 0, ${toString systemOpacity});
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

    /* Center launcher - styled as input field */
    #custom-launcher {
      background: #000000;
      color: #00FF00;
      padding: 0 10px;
      margin: 0 5px;
      border: 1px solid #00FF00;
      border-radius: 0px;
      font-family: monospace;
      font-size: 10px;
      min-width: 120px;
    }

    #custom-launcher:hover {
      background: #00FF00;
      color: #000000;
      border: 1px solid #00FF00;
    }

    /* Right modules - ultra compact */
    #cpu,
    #memory,
    #disk,
    #temperature,
    #backlight,
    #pulseaudio,
    #battery,
    #network,
    #tray,
    #clock {
      background: transparent;
      color: #FFFFFF;
      padding: 0 4px;
      margin: 0;
      border: none;
    }

    #cpu {
      color: #aaaaff;
    }

    #memory {
      color: #ffaaff;
    }

    #disk {
      color: #aaffaa;
    }

    #temperature.critical {
      color: #FF0000;
    }

    #backlight {
      color: #ffdd88;
    }

    #pulseaudio.muted {
      color: #888888;
    }

    #battery.charging {
      color: #88cc88;
    }

    #battery.warning:not(.charging) {
      color: #ffaa00;
    }

    #battery.critical:not(.charging) {
      color: #ff0000;
    }

    #network.disconnected {
      color: #ff0000;
    }

    #tray {
      padding: 0 5px;
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
    # Install waybar and fuzzel packages
    home.packages = with pkgs; [
      waybar
      fuzzel
    ];

    # Configure fuzzel to match waybar style with translucence
    xdg.configFile."fuzzel/fuzzel.ini".text = ''
      [main]
      font=monospace:size=10
      prompt=""
      icon-theme=Papirus-Dark
      terminal=ghostty
      layer=overlay
      width=40
      horizontal-pad=8
      vertical-pad=4
      inner-pad=4
      lines=15
      line-height=20

      [colors]
      background=000000${opacityToHex systemOpacity}
      text=ffffffff
      match=ffffffff
      selection=ffffffff
      selection-text=000000ff
      selection-match=ffffffff
      border=000000ff

      [border]
      width=1
      radius=0
    '';

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
        "SUPER, A, exec, ${pkgs.fuzzel}/bin/fuzzel"
      ];
      windowrulev2 = [
        "opacity ${toString systemOpacity} override,class:^(com.mitchellh.ghostty)$"
      ];
    };
  };
}