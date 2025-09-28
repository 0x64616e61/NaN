{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.waybarPureNix;

  # Pure Nix waybar configuration
  waybarConfig = {
    layer = "top";
    position = "top";
    height = 35;
    exclusive = true;
    passthrough = false;
    gtk-layer-shell = true;

    modules-left = [
      "hyprland/workspaces"
      "wlr/taskbar"
    ];

    modules-center = [
      "clock"
      "custom/weather"
      "idle_inhibitor"
    ];

    modules-right = [
      "tray"
      "network"
      "bluetooth"
      "pulseaudio"
      "battery"
      "cpu"
      "memory"
      "temperature"
      "custom/rotation-lock"
      "custom/notification"
      "custom/power"
    ];

    # Hyprland Workspaces
    "hyprland/workspaces" = {
      disable-scroll = false;
      all-outputs = true;
      on-click = "activate";
      format = "{icon}";
      format-icons = {
        "1" = "1";
        "2" = "2";
        "3" = "3";
        "4" = "4";
        "5" = "5";
        "6" = "6";
        "7" = "7";
        "8" = "8";
        "9" = "9";
        "10" = "10";
        urgent = "";
        default = "";
      };
      persistent-workspaces = {
        "*" = [ 1 2 3 4 5 ];
      };
    };

    # Window List
    "wlr/taskbar" = {
      format = "{icon}";
      icon-size = 14;
      icon-theme = "Papirus-Dark";
      tooltip-format = "{title}";
      on-click = "activate";
      on-click-middle = "close";
      on-click-right = "minimize";
      ignore-list = [ "Alacritty" "kitty" "ghostty" ];
    };

    # Clock
    clock = {
      interval = 1;
      format = "{:%H:%M:%S}";
      format-alt = "{:%A, %B %d, %Y}";
      tooltip-format = "<tt><small>{calendar}</small></tt>";
      calendar = {
        mode = "year";
        mode-mon-col = 3;
        weeks-pos = "right";
        on-scroll = 1;
        on-click-right = "mode";
        format = {
          months = "<span color='#ffead3'><b>{}</b></span>";
          days = "<span color='#ecc6d9'><b>{}</b></span>";
          weeks = "<span color='#99ffdd'><b>W{}</b></span>";
          weekdays = "<span color='#ffcc66'><b>{}</b></span>";
          today = "<span color='#ff6699'><b><u>{}</u></b></span>";
        };
      };
    };

    # Idle Inhibitor
    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = "";
        deactivated = "";
      };
      tooltip-format-activated = "Idle inhibitor: ON";
      tooltip-format-deactivated = "Idle inhibitor: OFF";
    };

    # System Tray
    tray = {
      icon-size = 14;
      spacing = 10;
    };

    # Network
    network = {
      interface = "*";
      format-wifi = " {signalStrength}%";
      format-ethernet = " {ipaddr}";
      format-disconnected = "󰖪";
      tooltip-format = "{ifname}: {ipaddr}/{cidr}";
      tooltip-format-wifi = "{essid} ({signalStrength}%): {ipaddr}";
      on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
    };

    # Bluetooth
    bluetooth = {
      format = "";
      format-disabled = "󰂲";
      format-connected = " {num_connections}";
      tooltip-format = "{controller_alias}\t{controller_address}";
      tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
      tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
      on-click = "${pkgs.blueberry}/bin/blueberry";
    };

    # Audio
    pulseaudio = {
      format = "{icon} {volume}%";
      format-muted = "";
      format-icons = {
        headphone = "";
        hands-free = "";
        headset = "";
        phone = "";
        portable = "";
        car = "";
        default = [ "" "" "" ];
      };
      on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      on-click-right = "${pkgs.pamixer}/bin/pamixer -t";
      scroll-step = 5;
    };

    # Battery
    battery = {
      states = {
        good = 95;
        warning = 30;
        critical = 15;
      };
      format = "{icon} {capacity}%";
      format-charging = " {capacity}%";
      format-plugged = " {capacity}%";
      format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      tooltip-format = "{timeTo}\n{capacity}% | {power}W";
    };

    # CPU
    cpu = {
      interval = 2;
      format = " {usage}%";
      tooltip = true;
      on-click = "${pkgs.btop}/bin/btop";
    };

    # Memory
    memory = {
      interval = 2;
      format = " {}%";
      tooltip-format = "RAM: {used:0.1f}G/{total:0.1f}G";
      on-click = "${pkgs.btop}/bin/btop";
    };

    # Temperature
    temperature = {
      hwmon-path = "/sys/class/thermal/thermal_zone0/temp";
      critical-threshold = 80;
      format = " {temperatureC}°C";
      format-critical = " {temperatureC}°C";
    };

    # Custom Weather Module
    "custom/weather" = {
      exec = "${pkgs.wttrbar}/bin/wttrbar --fahrenheit";
      return-type = "json";
      format = "{}";
      interval = 3600;
    };

    # Custom Notification Module
    "custom/notification" = {
      format = "{icon}";
      format-icons = {
        notification = "󱅫";
        none = "󰂚";
        dnd-notification = "󱅫";
        dnd-none = "󰂛";
      };
      return-type = "json";
      exec-if = "${pkgs.bash}/bin/bash -c 'which swaync-client'";
      exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
      on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
      on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
      escape = true;
    };

    # Custom Rotation Lock
    "custom/rotation-lock" = {
      format = "{}";
      exec = ''${pkgs.bash}/bin/bash -c "
        if [ -f /tmp/rotation-locked ]; then
          echo '{\"text\": \"🔒\", \"tooltip\": \"Rotation locked\", \"class\": \"locked\"}'
        else
          echo '{\"text\": \"🔓\", \"tooltip\": \"Rotation unlocked\", \"class\": \"unlocked\"}'
        fi"
      '';
      interval = 1;
      return-type = "json";
      on-click = ''${pkgs.bash}/bin/bash -c "
        if [ -f /tmp/rotation-locked ]; then
          rm /tmp/rotation-locked
          notify-send 'Rotation Unlocked' 'Screen will auto-rotate based on orientation'
        else
          touch /tmp/rotation-locked
          notify-send 'Rotation Locked' 'Screen orientation is now locked'
        fi"
      '';
    };

    # Custom Power Menu
    "custom/power" = {
      format = "⏻";
      tooltip = false;
      on-click = "${pkgs.wlogout}/bin/wlogout";
    };
  };

  # Waybar styles in pure Nix
  waybarStyle = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 13px;
      min-height: 0;
      padding: 0;
      margin: 0;
    }

    window#waybar {
      background-color: rgba(30, 30, 46, 0.85);
      color: #cdd6f4;
      transition-property: background-color;
      transition-duration: .5s;
    }

    window#waybar.hidden {
      opacity: 0.2;
    }

    /* Workspaces */
    #workspaces button {
      padding: 0 5px;
      background-color: transparent;
      color: #cdd6f4;
      border-bottom: 3px solid transparent;
      min-width: 20px;
    }

    #workspaces button:hover {
      background: rgba(203, 166, 247, 0.2);
      box-shadow: inherit;
    }

    #workspaces button.active {
      background-color: rgba(203, 166, 247, 0.3);
      border-bottom: 3px solid #cba6f7;
    }

    #workspaces button.urgent {
      background-color: rgba(243, 139, 168, 0.3);
      border-bottom: 3px solid #f38ba8;
    }

    /* Modules */
    #clock,
    #battery,
    #cpu,
    #memory,
    #temperature,
    #network,
    #bluetooth,
    #pulseaudio,
    #tray,
    #idle_inhibitor,
    #custom-rotation-lock,
    #custom-notification,
    #custom-weather,
    #custom-power {
      padding: 0 10px;
      margin: 3px 3px;
      background-color: rgba(49, 50, 68, 0.8);
      border-radius: 8px;
    }

    /* Battery states */
    #battery.charging,
    #battery.plugged {
      color: #a6e3a1;
      background-color: rgba(166, 227, 161, 0.1);
    }

    #battery.critical:not(.charging) {
      background-color: rgba(243, 139, 168, 0.2);
      color: #f38ba8;
      animation: blink 0.5s linear infinite alternate;
    }

    @keyframes blink {
      to {
        background-color: rgba(243, 139, 168, 0.3);
      }
    }

    #battery.warning:not(.charging) {
      background-color: rgba(250, 227, 176, 0.2);
      color: #fab387;
    }

    /* Network */
    #network.disconnected {
      background-color: rgba(243, 139, 168, 0.2);
      color: #f38ba8;
    }

    /* Pulseaudio */
    #pulseaudio.muted {
      background-color: rgba(137, 180, 250, 0.2);
      color: #89b4fa;
    }

    /* Temperature */
    #temperature.critical {
      background-color: rgba(243, 139, 168, 0.2);
      color: #f38ba8;
    }

    /* Tray */
    #tray > .passive {
      -gtk-icon-effect: dim;
    }

    #tray > .needs-attention {
      -gtk-icon-effect: highlight;
      background-color: rgba(243, 139, 168, 0.2);
    }

    /* Idle inhibitor */
    #idle_inhibitor.activated {
      background-color: rgba(166, 227, 161, 0.2);
      color: #a6e3a1;
    }

    /* Custom modules */
    #custom-power {
      color: #f38ba8;
      background-color: rgba(243, 139, 168, 0.2);
    }

    #custom-weather {
      background-color: rgba(137, 220, 235, 0.2);
    }

    #custom-notification {
      background-color: rgba(203, 166, 247, 0.2);
    }

    /* Rotation lock */
    #custom-rotation-lock {
      background-color: rgba(147, 153, 178, 0.2);
      padding: 0 8px;
    }

    #custom-rotation-lock.locked {
      color: #f38ba8;
      background-color: rgba(243, 139, 168, 0.2);
    }

    #custom-rotation-lock.unlocked {
      color: #a6e3a1;
      background-color: rgba(166, 227, 161, 0.2);
    }

    /* Tooltips */
    tooltip {
      background: rgba(30, 30, 46, 0.95);
      border: 1px solid rgba(203, 166, 247, 0.5);
      border-radius: 8px;
    }

    tooltip label {
      color: #cdd6f4;
      padding: 5px;
    }
  '';

in
{
  options.custom.hm.desktop.waybarPureNix = {
    enable = mkEnableOption "pure Nix waybar configuration without Python dependencies";

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically start waybar with Hyprland";
    };

    systemdIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Use systemd to manage waybar service";
    };
  };

  config = mkIf cfg.enable {
    # Install waybar package
    home.packages = with pkgs; [
      waybar
      wttrbar
      pamixer
      pavucontrol
      networkmanagerapplet
      blueberry
    ];

    # Waybar configuration
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = waybarConfig;
      };
      style = waybarStyle;
      systemd = {
        enable = cfg.systemdIntegration;
        target = "hyprland-session.target";
      };
    };

    # Ensure waybar starts with Hyprland
    wayland.windowManager.hyprland.settings = mkIf cfg.autoStart {
      exec-once = [
        "${pkgs.waybar}/bin/waybar"
      ];
    };

    # Create systemd service for waybar management
    systemd.user.services.waybar = mkIf cfg.systemdIntegration {
      Unit = {
        Description = "Waybar - Wayland bar";
        Documentation = "https://github.com/Alexays/Waybar/wiki";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session-pre.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.waybar}/bin/waybar";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
        Restart = "on-failure";
        RestartSec = 1;

        # Performance tuning
        CPUSchedulingPolicy = "batch";
        Nice = 19;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Kill any existing Python waybar processes on activation
    home.activation.killPythonWaybar = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Cleaning up Python waybar processes..."
      ${pkgs.procps}/bin/pkill -f "python.*waybar" || true
      ${pkgs.procps}/bin/pkill -f "waybar.py" || true
    '';
  };
}