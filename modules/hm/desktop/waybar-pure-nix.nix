{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.waybarPureNix;

  # Pure Nix waybar configuration
  waybarConfig = {
    layer = "top";
    position = "top";
    height = 52; # GPD Pocket 3: Increased for 1.5x scaling + touch targets (35 * 1.5 ≈ 52px)
    exclusive = true;
    passthrough = false;
    gtk-layer-shell = true;

    modules-left = [
      "hyprland/workspaces"
      "wlr/taskbar"
    ];

    modules-center = [
      "clock"
      # GPD Pocket 3: Compact center for handheld screen real estate
      "idle_inhibitor"
    ];

    modules-right = [
      # GPD Pocket 3: Prioritized modules for handheld usage
      "battery"          # Critical for handheld device
      "network"          # Essential connectivity status
      "pulseaudio"       # Audio control for multimedia
      "custom/rotation-lock"  # Hardware-specific rotation control
      "temperature"      # Thermal monitoring for compact device
      "custom/weather"   # Moved from center to save space
      "custom/notification"  # Notification management
      "tray"            # System tray (minimal icons only)
      "custom/power"    # Power management access
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

    # Window List - GPD Pocket 3 optimized
    "wlr/taskbar" = {
      format = "{icon}";
      icon-size = 22; # GPD Pocket 3: Increased from 14 for 1.5x scaling (14 * 1.5 ≈ 22px)
      icon-theme = "Papirus-Dark";
      tooltip-format = "{title}";
      on-click = "activate";
      on-click-middle = "close";
      on-click-right = "minimize";
      ignore-list = [ "Alacritty" "kitty" "ghostty" ];
      # GPD Pocket 3: Optimize for small screen real estate
      all-outputs = false; # Only show on current workspace
      markup = true;
    };

    # Clock - GPD Pocket 3 optimized
    clock = {
      interval = 1;
      format = "{:%H:%M}"; # GPD: Removed seconds to save horizontal space
      format-alt = "{:%a %m/%d}"; # GPD: Compact date format for small screen
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

    # System Tray - GPD Pocket 3 optimized
    tray = {
      icon-size = 22; # GPD Pocket 3: Increased from 14 for 1.5x scaling (14 * 1.5 ≈ 22px)
      spacing = 8; # GPD Pocket 3: Reduced spacing to conserve horizontal space
      show-passive-items = false; # GPD Pocket 3: Hide inactive items to save space
    };

    # Network - GPD Pocket 3 compact format
    network = {
      interface = "*";
      format-wifi = " {signalStrength}%"; # GPD: Concise signal strength display
      format-ethernet = " 󰈀"; # GPD: Icon-only for wired (saves space)
      format-disconnected = "󰖪"; # GPD: Clear disconnection indicator
      tooltip-format = "{ifname}: {ipaddr}/{cidr}";
      tooltip-format-wifi = "{essid} ({signalStrength}%): {ipaddr}";
      on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
      # GPD: Compact format prioritizes essential info for small screen
      max-length = 12;
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

    # Battery - GPD Pocket 3 critical status display
    battery = {
      states = {
        good = 95;
        warning = 30;
        critical = 15; # GPD: Critical threshold for handheld device
      };
      format = "{icon} {capacity}%";
      format-charging = " {capacity}%"; # GPD: Clear charging indicator
      format-plugged = " {capacity}%";
      format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      tooltip-format = "{timeTo}\n{capacity}% | {power}W";
      # GPD: Enhanced battery monitoring for portable device
      format-time = "{H}h {M}m"; # Compact time format
      format-full = " {capacity}%"; # Full charge indicator
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

  # GPD Pocket 3 optimized waybar styles with touch-friendly design
  waybarStyle = ''
    /*
     * GPD Pocket 3 Hardware-Specific Waybar Configuration
     * ================================================
     *
     * HARDWARE SPECIFICATIONS:
     * - Display: 7-inch IPS touchscreen, 1920x1200 native resolution
     * - Configured: 1200x1920 with transform 3 (270° landscape rotation)
     * - Scaling: 1.5x factor (effective 800x1280 logical pixels)
     * - Touch Input: GXTP7380:00 27C6:0113 device on /dev/input/event18
     * - Form Factor: Handheld UMPC optimized for one-handed operation
     *
     * TOUCH OPTIMIZATION RATIONALE:
     * - Minimum 48px touch targets (WCAG AAA compliance for mobile)
     * - Increased font sizes (13px base) for 7-inch screen readability
     * - Enhanced contrast (pure white text) for outdoor visibility
     * - Larger padding/margins to prevent accidental touches
     * - Stronger visual feedback (scale, shadows) for touch confidence
     * - Optimized spacing for thumb navigation in landscape mode
     *
     * HANDHELD USAGE PATTERNS:
     * - One-handed operation with thumb interaction
     * - Outdoor/mobile use requiring high contrast
     * - Limited screen real estate requiring information density
     * - Quick glance information consumption patterns
     * - Battery-conscious display with readable status indicators
     */

    /* GPD Hardware Design Variables - High contrast for outdoor use */
    @define-color gpd-primary #8B5CF6;         /* High contrast purple */
    @define-color gpd-secondary #6366F1;       /* Accent blue */
    @define-color gpd-accent #EC4899;          /* Alert pink */
    @define-color gpd-success #10B981;         /* Success green - high contrast */
    @define-color gpd-warning #F59E0B;         /* Warning amber - visible outdoors */
    @define-color gpd-error #EF4444;           /* Error red - immediate attention */
    @define-color gpd-bg rgba(8, 8, 12, 0.95); /* Darker background for contrast */
    @define-color gpd-surface rgba(20, 20, 30, 0.90); /* Surface with better contrast */
    @define-color gpd-text #FFFFFF;            /* Pure white for readability */
    @define-color gpd-text-dim #D1D5DB;        /* Light gray for secondary text */
    @define-color gpd-border rgba(75, 85, 99, 0.6); /* More visible borders */

    /* GPD Typography - Optimized for 7-inch display with 1.5x scaling */
    * {
      font-family: "Inter", "SF Pro Display", "JetBrainsMono Nerd Font", sans-serif;
      font-size: 13px; /* GPD: Increased from 11px for 1.5x scale readability */
      font-weight: 600; /* GPD: Heavier weight for small screen clarity */
      min-height: 0;
      padding: 0;
      margin: 0;
      border: none;
      border-radius: 0;
      /* GPD: Enable font smoothing for crisp text on small screen */
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }

    /* Main Bar - GPD Pocket 3 handheld optimizations */
    window#waybar {
      background: @gpd-bg;
      color: @gpd-text;
      border-bottom: 2px solid @gpd-border; /* GPD: Thicker border for definition */
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      /* GPD: Add subtle shadow for depth on small screen */
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
    }

    window#waybar.hidden {
      opacity: 0;
      margin-top: -52px; /* GPD: Updated for new height (was -35px) */
    }

    /* Workspace Design - GPD touch-optimized with high contrast */
    #workspaces {
      background: linear-gradient(90deg,
        alpha(@gpd-primary, 0.15) 0%,
        alpha(@gpd-secondary, 0.08) 100%);
      border-radius: 14px; /* GPD: Larger radius for better touch feel */
      padding: 4px 6px; /* GPD: Increased padding for touch targets */
      margin: 6px 8px; /* GPD: More margin for easier thumb access */
      /* GPD: Add border for better definition on small screen */
      border: 1px solid @gpd-border;
    }

    #workspaces button {
      color: @gpd-text-dim;
      padding: 8px 12px; /* GPD: Significantly larger touch targets */
      margin: 3px 3px; /* GPD: More spacing between touch targets */
      background: transparent;
      border-radius: 10px; /* GPD: Larger radius for thumb-friendly feel */
      min-width: 48px; /* GPD: WCAG AAA minimum touch target (44px+) */
      min-height: 36px; /* GPD: Adequate touch height */
      transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1); /* GPD: Slightly slower for handheld */
      font-weight: 700; /* GPD: Bolder for small screen readability */
      /* GPD: Add subtle background for better target recognition */
      border: 1px solid transparent;
    }

    #workspaces button:hover {
      background: alpha(@gpd-primary, 0.25); /* GPD: Stronger hover for touch feedback */
      color: @gpd-text;
      /* transform not supported in GTK CSS - using padding instead */
      padding: 9px 13px; /* GPD: Slightly larger padding for hover effect */
      border-color: @gpd-primary;
    }

    #workspaces button.active {
      background: linear-gradient(135deg, @gpd-primary, @gpd-secondary);
      color: white;
      box-shadow: 0 3px 12px alpha(@gpd-primary, 0.4); /* GPD: Stronger shadow for depth */
      font-weight: 800; /* GPD: Extra bold for active state visibility */
      border-color: @gpd-primary;
    }

    #workspaces button.urgent {
      background: @gpd-error;
      color: white;
      animation: pulse 1s infinite;
      border-color: @gpd-error;
      /* GPD: Add stronger urgent animation for attention */
      box-shadow: 0 0 15px alpha(@gpd-error, 0.6);
    }

    @keyframes pulse {
      0% { opacity: 1; }
      50% { opacity: 0.7; }
      100% { opacity: 1; }
    }

    /* Module Groups - GPD Pocket 3 touch-optimized with 48px+ targets */
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
      /* GPD: Optimized touch targets for 7-inch handheld device */
      min-height: 40px;  /* GPD: Increased from 32px for better thumb access */
      min-width: 50px;   /* GPD: Exceeded WCAG AAA (48px+) for comfortable touch */
      padding: 8px 14px; /* GPD: Larger padding for easier targeting */
      margin: 3px 4px;   /* GPD: More margin to prevent accidental touches */
      background: @gpd-surface;
      border: 1px solid @gpd-border;
      border-radius: 12px; /* GPD: Larger radius for handheld comfort */
      transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1); /* GPD: Slower transition for handheld */
      font-weight: 700; /* GPD: Bolder text for small screen readability */
      /* display/align/justify not supported in GTK CSS - using padding for centering */
      /* GPD: Enhanced contrast and visibility for outdoor use */
      text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.8);
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
    }

    /* GPD Touch hover states - Enhanced for handheld interaction */
    #clock:hover,
    #battery:hover,
    #cpu:hover,
    #memory:hover,
    #temperature:hover,
    #network:hover,
    #bluetooth:hover,
    #pulseaudio:hover,
    #idle_inhibitor:hover,
    #custom-rotation-lock:hover,
    #custom-notification:hover,
    #custom-weather:hover,
    #custom-power:hover {
      background: alpha(@gpd-primary, 0.2); /* GPD: Stronger hover for better feedback */
      border-color: @gpd-primary;
      /* transform not supported in GTK - using visual effects instead */
      cursor: pointer;
      /* GPD: Enhanced visual feedback for touch */
      box-shadow: 0 4px 12px alpha(@gpd-primary, 0.3);
      text-shadow: 1px 1px 3px rgba(0, 0, 0, 1.0);
    }

    /* GPD Active/pressed state - Strong tactile feedback for touch */
    #clock:active,
    #battery:active,
    #cpu:active,
    #memory:active,
    #temperature:active,
    #network:active,
    #bluetooth:active,
    #pulseaudio:active,
    #idle_inhibitor:active,
    #custom-rotation-lock:active,
    #custom-notification:active,
    #custom-weather:active,
    #custom-power:active {
      /* transform not supported in GTK - using inset shadow for press effect */
      background: alpha(@gpd-primary, 0.35); /* GPD: More visible active state */
      border-color: @gpd-secondary;
      /* GPD: Immediate visual confirmation of touch */
      box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.4);
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

    /* GPD Tooltips - Enhanced for touch interaction */
    tooltip {
      background: rgba(8, 8, 12, 0.98); /* GPD: Higher opacity for readability */
      border: 2px solid @gpd-primary; /* GPD: Thicker border for visibility */
      border-radius: 12px; /* GPD: Larger radius for handheld aesthetic */
      /* GPD: Enhanced shadow for better definition on small screen */
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.5);
    }

    tooltip label {
      color: @gpd-text; /* GPD: Use consistent text color */
      padding: 8px 12px; /* GPD: Larger padding for touch-friendly tooltips */
      font-size: 12px; /* GPD: Slightly smaller than main text for hierarchy */
      font-weight: 600; /* GPD: Bold for readability */
    }

    /* GPD Pocket 3 Specific Optimizations */

    /* Taskbar optimization for small screen real estate */
    #taskbar button {
      /* GPD: Compact taskbar buttons to fit more windows */
      min-width: 40px;
      padding: 6px 8px;
      margin: 2px;
      border-radius: 8px;
      font-size: 11px; /* Smaller text for taskbar items */
    }

    /* Clock center positioning for balanced layout */
    #clock {
      /* GPD: Make clock slightly more prominent as primary time reference */
      font-size: 14px;
      font-weight: 800;
      letter-spacing: 0.5px;
    }

    /* Power button emphasis for critical function */
    #custom-power {
      /* GPD: Make power button more prominent for safety */
      border: 2px solid @gpd-error;
      font-size: 15px;
      font-weight: 800;
    }

    #custom-power:hover {
      background: alpha(@gpd-error, 0.2);
      border-color: @gpd-error;
      /* GPD: Strong visual warning for power button */
      box-shadow: 0 0 20px alpha(@gpd-error, 0.6);
    }

    /* Battery status critical visibility */
    #battery.critical {
      /* GPD: Maximum visibility for critical battery on portable device */
      animation: urgent-pulse 0.8s ease-in-out infinite alternate;
      border: 2px solid @gpd-error;
    }

    @keyframes urgent-pulse {
      from {
        background: alpha(@gpd-error, 0.2);
        /* scale effect via opacity and shadow */
      }
      to {
        background: alpha(@gpd-error, 0.4);
        /* scale effect via shadow expansion */
      }
    }

    /* Network status optimization for mobile connectivity */
    #network.disconnected {
      /* GPD: Clear disconnection warning for mobile device */
      animation: warning-blink 1.5s ease-in-out infinite;
      border: 2px solid @gpd-warning;
    }

    @keyframes warning-blink {
      0% { opacity: 1; }
      50% { opacity: 0.6; }
      100% { opacity: 1; }
    }

    /* Rotation lock prominence for hardware feature */
    #custom-rotation-lock {
      /* GPD: Emphasize rotation control as key hardware feature */
      font-size: 14px;
      border: 1px solid @gpd-border;
    }

    #custom-rotation-lock.locked {
      /* GPD: Clear visual feedback for locked rotation */
      animation: none; /* Stop any animations when locked */
      border-color: @gpd-error;
    }

    #custom-rotation-lock.unlocked {
      /* GPD: Subtle animation to indicate auto-rotation active */
      border-color: @gpd-success;
      animation: gentle-pulse 3s ease-in-out infinite;
    }

    @keyframes gentle-pulse {
      0% { opacity: 1; }
      50% { opacity: 0.8; }
      100% { opacity: 1; }
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
        Description = mkForce "Waybar - Wayland bar";
        Documentation = mkForce "https://github.com/Alexays/Waybar/wiki";
        PartOf = mkForce [ "graphical-session.target" ];
        After = mkForce [ "graphical-session-pre.target" ];
      };

      Service = {
        Type = mkForce "simple";
        ExecStart = mkForce "${pkgs.waybar}/bin/waybar";
        ExecReload = mkForce "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
        Restart = mkForce "on-failure";
        RestartSec = mkForce 1;

        # Performance tuning
        CPUSchedulingPolicy = mkForce "batch";
        Nice = mkForce 19;
        IOSchedulingClass = mkForce "idle";
        IOSchedulingPriority = mkForce 7;
      };

      Install = {
        WantedBy = mkForce [ "hyprland-session.target" ];
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