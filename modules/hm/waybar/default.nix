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
          
          modules-left = [ "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "clock" ];
          modules-right = [ "tray" "network" "battery" "pulseaudio" ];
          
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
              "(.*) — Mozilla Firefox" = "🌐 $1";
              "(.*) - Ghostty" = "⌨️ $1";
            };
          };
          
          clock = {
            format = "{:%H:%M}";
            format-alt = "{:%Y-%m-%d}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
          };
          
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "⚡ {capacity}%";
            format-plugged = "🔌 {capacity}%";
            format-icons = [ "🔋" "🔋" "🔋" "🔋" "🔋" ];
          };
          
          network = {
            format-wifi = "📶 {signalStrength}%";
            format-ethernet = "🌐 Connected";
            format-disconnected = "⚠️ Disconnected";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          };
          
          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "🔇 Muted";
            format-icons = {
              default = [ "🔈" "🔉" "🔊" ];
            };
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };
          
          tray = {
            spacing = 10;
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
          background-color: rgba(0, 0, 0, 0.9);
          color: #ffffff;
          border-bottom: 2px solid #00ff00;
        }
        
        #workspaces button {
          padding: 0 10px;
          color: #888888;
          background-color: transparent;
          border-radius: 0;
        }
        
        #workspaces button:hover {
          background: rgba(0, 255, 0, 0.2);
          color: #00ff00;
        }
        
        #workspaces button.active {
          color: #00ff00;
          background-color: rgba(0, 255, 0, 0.1);
        }
        
        #workspaces button.urgent {
          background-color: #ff0000;
          color: #ffffff;
        }
        
        #clock,
        #battery,
        #network,
        #pulseaudio,
        #tray,
        #window {
          padding: 0 10px;
          color: #ffffff;
        }
        
        #battery.charging {
          color: #00ff00;
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
    ];
  };
}