{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.waybar;
in
{
  options.custom.hm.waybar = {
    enable = mkEnableOption "Pure Nix waybar configuration";
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 25;
          spacing = 0;
          
          modules-left = [ "custom/launcher" "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "clock" ];
          modules-right = [
            "tray"
            "idle_inhibitor"
            "cpu"
            "memory"
            "disk"
            "temperature"
            "backlight"
            "network"
            "battery"
            "pulseaudio"
            "custom/power"
          ];
          
          "hyprland/workspaces" = {
            format = "{id}";
            on-click = "activate";
            disable-scroll = false;
            all-outputs = true;
          };
          
          "hyprland/window" = {
            format = "{title}";
            max-length = 50;
            rewrite = {
              "(.*) — Mozilla Firefox" = "◈ $1";
              "(.*) - Ghostty" = "▸ $1";
            };
          };
          
          clock = {
            format = "{:%H:%M}";
            format-alt = "{:%Y-%m-%d}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            on-click-right = "gnome-calendar";
          };

          cpu = {
            format = "▪ {usage}%";
            tooltip = true;
            on-click = "ghostty -e btop";
          };

          memory = {
            format = "▫ {percentage}%";
            tooltip-format = "{used:0.1f}G / {total:0.1f}G used";
            on-click = "ghostty -e btop";
          };

          disk = {
            format = "◊ {percentage_used}%";
            path = "/";
            tooltip-format = "{used} / {total} used ({percentage_used}%)";
            on-click = "ghostty -e ncdu /";
          };

          backlight = {
            format = "☼ {percent}%";
            on-scroll-up = "brightnessctl set +5%";
            on-scroll-down = "brightnessctl set 5%-";
            tooltip-format = "Brightness: {percent}%";
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "◉";
              deactivated = "○";
            };
            tooltip-format-activated = "Idle inhibitor: active";
            tooltip-format-deactivated = "Idle inhibitor: inactive";
          };
          
          temperature = {
            hwmon-path = "/sys/class/thermal/thermal_zone5/temp";
            format = "T:{temperatureC}°";
            critical-threshold = 80;
            tooltip = false;
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "↑ {capacity}%";
            format-plugged = "● {capacity}%";
            format-icons = [ "▁" "▃" "▅" "▇" "█" ];
            format-time = "{H}h {M}m";
            tooltip-format = "{timeTo}, {power}W";
            on-click = "battery-status";
          };
          
          network = {
            format-wifi = "≈ {signalStrength}%";
            format-ethernet = "⊞ {bandwidthDownBits}";
            format-disconnected = "✗ Disconnected";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}\n↓ {bandwidthDownBits} ↑ {bandwidthUpBits}";
            tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}/{cidr}\n↓ {bandwidthDownBits} ↑ {bandwidthUpBits}";
            on-click = "nm-connection-editor";
            interval = 2;
          };
          
          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "◌ Muted";
            format-icons = {
              default = [ "▁" "▃" "▇" ];
            };
            on-click = "pavucontrol";
            on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
            on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
            scroll-step = 5;
          };
          
          "custom/launcher" = {
            format = " ▶ ";
            on-click = "/home/a/.local/bin/launch-dmenu";
            tooltip = false;
          };
          
          tray = {
            spacing = 10;
            icon-size = 16;
          };

          "custom/power" = {
            format = "⏻";
            on-click = "wlogout";
            tooltip = false;
          };
        };
      };
      
      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 13px;
          min-height: 0;
        }
        
        window#waybar {
          background-color: rgba(0, 0, 0, 0.85);
          color: #cccccc;
          border-bottom: 1px solid #444444;
        }
        
        #workspaces button {
          padding: 0 10px;
          color: #888888;
          background-color: transparent;
          border-radius: 0;
        }
        
        #workspaces button:hover {
          background: rgba(255, 255, 255, 0.1);
          color: #ffffff;
        }
        
        #workspaces button.active {
          color: #ffffff;
          background-color: rgba(255, 255, 255, 0.1);
        }
        
        #workspaces button.urgent {
          background-color: #ff0000;
          color: #ffffff;
        }
        
        #custom-launcher {
          padding: 0 10px;
          color: #ffffff;
          background-color: #333333;
          border-right: 1px solid #444444;
        }
        
        #custom-launcher:hover {
          background-color: #555555;
        }
        
        #clock,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #battery,
        #network,
        #pulseaudio,
        #idle_inhibitor,
        #tray,
        #custom-power,
        #window {
          padding: 0 10px;
          color: #cccccc;
        }

        #cpu,
        #memory,
        #disk {
          color: #aaaaff;
        }

        #backlight {
          color: #ffdd88;
        }

        #idle_inhibitor {
          color: #88ff88;
        }

        #idle_inhibitor.activated {
          color: #ff8888;
        }

        #custom-power {
          color: #ff6666;
          background-color: #222222;
          border-left: 1px solid #444444;
        }

        #custom-power:hover {
          background-color: #ff0000;
          color: #ffffff;
        }

        #temperature.critical {
          color: #ff0000;
        }
        
        #battery.charging {
          color: #88cc88;
        }
        
        #battery.warning:not(.charging) {
          color: #ffaa00;
        }
        
        #battery.critical:not(.charging) {
          background-color: #ff0000;
          color: #ffffff;
          animation: blink 0.5s linear infinite alternate;
        }
        
        #network.disconnected {
          color: #ff0000;
        }
        
        #pulseaudio.muted {
          color: #888888;
        }
        
        @keyframes blink {
          to {
            background-color: #000000;
            color: #ff0000;
          }
        }
      '';
    };
    
    # Install required packages
    home.packages = with pkgs; [
      pavucontrol
      brightnessctl
      wlogout
      btop
      ncdu
      networkmanagerapplet
    ];
  };
}