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
          spacing = 0;

          modules-left = [ "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "clock" ];
          modules-right = [
            "tray"
            "idle_inhibitor"
            "cpu"
            "memory"
            "disk"
            "temperature"
            "network"
            "pulseaudio"
            "battery"
            "backlight"
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
            interval = 1;
            tooltip = true;
            on-click = "ghostty -e btop";
          };

          memory = {
            format = "▫ {percentage}%";
            interval = 2;
            tooltip-format = "{used:0.1f}G / {total:0.1f}G used";
            on-click = "ghostty -e btop";
          };

          disk = {
            format = "◊ {percentage_used}%";
            path = "/";
            interval = 30;
            tooltip-format = "{used} / {total} used ({percentage_used}%)";
            on-click = "ghostty -e ncdu /";
          };

          backlight = {
            format = "{icon}";
            format-icons = [ "▁" "▃" "▅" "▇" "█" ];
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
            interval = 2;
            critical-threshold = 80;
            tooltip = false;
          };

          battery = {
            interval = 5;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "Discharging: {capacity}%";
            format-charging = "Charging: {capacity}%";
            format-plugged = "Charging: {capacity}%";
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
            interval = 1;
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "◌ Muted";
            format-icons = {
              default = [ "▁" "▃" "▇" ];
            };
            max-volume = 200;
            on-click = "pavucontrol";
            on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
            on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +5%";
            on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -5%";
            scroll-step = 5;
          };

          tray = {
            spacing = 10;
            icon-size = 16;
          };
        };
      };
      
      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 13px;
          min-height: 0;
          transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
        }

        window#waybar {
          background-color: #000000;
          color: #ffffff;
          border: none;
        }

        #workspaces button {
          padding: 0 8px;
          min-width: 0;
          color: #ffffff;
          background-color: transparent;
          border-radius: 0;
          transition: all 0.15s ease-out;
        }

        #workspaces button:hover {
          background: rgba(255, 255, 255, 0.15);
          color: #ffffff;
        }

        #workspaces button.active {
          color: #ffffff;
          background-color: rgba(255, 255, 255, 0.2);
        }

        #workspaces button.urgent {
          background-color: #ff0000;
          color: #ffffff;
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
        #window {
          padding: 0 10px;
          color: #ffffff;
        }

        #temperature.critical {
          color: #ff0000;
        }

        #battery.critical:not(.charging) {
          background-color: #ff0000;
          color: #ffffff;
          animation: blink 0.5s linear infinite alternate;
        }

        #network.disconnected {
          color: #ff0000;
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