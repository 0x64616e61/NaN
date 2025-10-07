{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.dwl;
in
{
  options.custom.hm.dwl = {
    enable = mkEnableOption "DWL window manager configuration";
  };

  config = mkIf cfg.enable {
    # DWL startup script
    home.file.".local/bin/start-dwl" = {
      text = ''
        #!/usr/bin/env bash
        # DWL startup script

        # Start background services
        if [ -f ~/.config/wallpaper.png ] && [ -s ~/.config/wallpaper.png ]; then
          ${pkgs.swaybg}/bin/swaybg -i ~/.config/wallpaper.png &
        else
          ${pkgs.swaybg}/bin/swaybg -c '#1e1e2e' &  # Catppuccin Mocha bg color
        fi

        # Start notification daemon (must be in compositor process tree for Wayland)
        ${pkgs.dunst}/bin/dunst &

        # Start idle management with comprehensive locking
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 120 '${pkgs.swaylock}/bin/swaylock -f' \
          timeout 900 'systemctl suspend' \
          before-sleep '${pkgs.swaylock}/bin/swaylock -f' \
          lock '${pkgs.swaylock}/bin/swaylock -f' &

        # Start eww status bar
        ${pkgs.eww}/bin/eww daemon &
        sleep 1
        ${pkgs.eww}/bin/eww open bar &

        # Map touchscreen input to HDMI output (external monitor)
        # This makes the GPD touchscreen control the HDMI display
        export LIBINPUT_CALIBRATION_MATRIX="1 0 0 0 1 0"

        # Create input mapping config for wlroots
        # Maps GXTP7380 touchscreen to HDMI-A-1 output
        export WLR_OUTPUT_HDMI_A_1_ENABLED=1

        # Start dwl
        exec ${pkgs.dwl}/bin/dwl
      '';
      executable = true;
    };

    # DWL status bar scripts
    home.file.".local/bin/dwl-status/status" = {
      text = ''
        #!/usr/bin/env bash
        while true; do
          TIME=$(date '+%H:%M')
          DATE=$(date '+%a %d %b')
          BATTERY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "100")
          STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "")

          if [ "$STATUS" = "Charging" ]; then
            BAT_ICON="󰂄"
          else
            BAT_ICON="󰁹"
          fi

          echo "$BAT_ICON $BATTERY% | $TIME $DATE"
          sleep 1
        done
      '';
      executable = true;
    };

    # Enhanced status bar script with comprehensive metrics
    home.file.".local/bin/dwl-status/status-enhanced" = {
      text = ''
        #!/usr/bin/env bash
        # Enhanced status script for dwlb - comprehensive system metrics v2

        # Initialize CPU tracking variables
        prev_idle=0
        prev_total=0
        iter_count=0
        cached_disk=""
        cached_wifi=""

        get_cpu() {
            # Efficient CPU usage calculation without sleep using awk
            local cpu_line=$(grep '^cpu ' /proc/stat)
            local user=$(echo $cpu_line | awk '{print $2}')
            local nice=$(echo $cpu_line | awk '{print $3}')
            local system=$(echo $cpu_line | awk '{print $4}')
            local idle=$(echo $cpu_line | awk '{print $5}')
            local iowait=$(echo $cpu_line | awk '{print $6}')
            local irq=$(echo $cpu_line | awk '{print $7}')
            local softirq=$(echo $cpu_line | awk '{print $8}')
            local steal=$(echo $cpu_line | awk '{print $9}')

            local idle_time=$idle
            local total_time=$((user + nice + system + idle + iowait + irq + softirq + steal))

            if [ $prev_total -ne 0 ]; then
                local idle_delta=$((idle_time - prev_idle))
                local total_delta=$((total_time - prev_total))
                if [ $total_delta -ne 0 ]; then
                    local usage=$((100 * (total_delta - idle_delta) / total_delta))
                    echo "''${usage}%"
                else
                    echo "0%"
                fi
            else
                echo "0%"
            fi

            prev_idle=$idle_time
            prev_total=$total_time
        }

        get_memory() {
            free -h | awk '/^Mem:/ {gsub(/Gi/,"G",$3); gsub(/Gi/,"G",$2); gsub(/Mi/,"M",$3); gsub(/Mi/,"M",$2); print $3 "/" $2}'
        }

        get_disk() {
            # Cache disk usage (updates every ~30 seconds)
            df -h / | awk 'NR==2 {print $3 "/" $2}' | sed 's/G//g'
        }

        get_temp() {
            # CPU temperature
            if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
                temp=$(cat /sys/class/thermal/thermal_zone0/temp)
                echo "$((temp / 1000))°C"
            else
                echo ""
            fi
        }

        get_network() {
            # WiFi with SSID and signal
            if command -v iwgetid &>/dev/null; then
                ssid=$(iwgetid -r 2>/dev/null)
                if [ -n "$ssid" ]; then
                    # Get signal quality
                    quality=$(grep "$(iwgetid -a | awk '{print $1}')" /proc/net/wireless 2>/dev/null | awk '{print $3}' | sed 's/\.//')
                    if [ -n "$quality" ]; then
                        echo "󰖩 $ssid"
                    else
                        echo "󰖩 $ssid"
                    fi
                else
                    echo "󰖪 Off"
                fi
            elif ip route get 1.1.1.1 &>/dev/null 2>&1; then
                echo "󰖩 On"
            else
                echo "󰖪 Off"
            fi
        }

        get_volume() {
            if command -v pactl &>/dev/null; then
                vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk '{print $5}' | head -1 | sed 's/%//')
                if [ -n "$vol" ]; then
                    echo "''${vol}%"
                fi
            fi
        }

        get_brightness() {
            if [ -d /sys/class/backlight ]; then
                backlight=$(ls /sys/class/backlight/ 2>/dev/null | head -1)
                if [ -n "$backlight" ]; then
                    current=$(cat /sys/class/backlight/$backlight/brightness 2>/dev/null)
                    max=$(cat /sys/class/backlight/$backlight/max_brightness 2>/dev/null)
                    if [ -n "$current" ] && [ -n "$max" ] && [ "$max" -ne 0 ]; then
                        echo "$((current * 100 / max))%"
                    fi
                fi
            fi
        }

        get_battery() {
            if [ -f /sys/class/power_supply/BAT0/capacity ]; then
                battery=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
                status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)

                # Smart battery icons based on percentage
                if [ "$status" = "Charging" ]; then
                    bat_icon="󰂄"
                elif [ "$battery" -ge 90 ]; then
                    bat_icon="󰂂"
                elif [ "$battery" -ge 80 ]; then
                    bat_icon="󰂁"
                elif [ "$battery" -ge 70 ]; then
                    bat_icon="󰂀"
                elif [ "$battery" -ge 60 ]; then
                    bat_icon="󰁿"
                elif [ "$battery" -ge 50 ]; then
                    bat_icon="󰁾"
                elif [ "$battery" -ge 40 ]; then
                    bat_icon="󰁽"
                elif [ "$battery" -ge 30 ]; then
                    bat_icon="󰁼"
                elif [ "$battery" -ge 20 ]; then
                    bat_icon="󰁻"
                elif [ "$battery" -ge 10 ]; then
                    bat_icon="󰁺"
                else
                    bat_icon="󰂎"
                fi

                echo "$bat_icon $battery%"
            else
                echo ""
            fi
        }

        # Main loop
        while true; do
            # Update cached values periodically
            if [ $((iter_count % 15)) -eq 0 ]; then
                cached_disk=$(get_disk)
            fi
            if [ $((iter_count % 5)) -eq 0 ]; then
                cached_wifi=$(get_network)
            fi

            # Get dynamic metrics
            CPU=$(get_cpu)
            MEM=$(get_memory)
            TEMP=$(get_temp)
            VOL=$(get_volume)
            BRT=$(get_brightness)
            BAT=$(get_battery)
            TIME=$(date '+%H:%M')
            DATE=$(date '+%a %d %b')

            # Build status line with only available metrics
            status=""
            [ -n "$cached_disk" ] && status="$status󰋊 $cached_disk | "
            [ -n "$TEMP" ] && status="$status🌡️ $TEMP | "
            [ -n "$CPU" ] && status="$status󰻠 $CPU | "
            [ -n "$MEM" ] && status="$status󰍛 $MEM | "
            [ -n "$cached_wifi" ] && status="$status$cached_wifi | "
            [ -n "$VOL" ] && status="$status󰕾 $VOL | "
            [ -n "$BRT" ] && status="$status󰃟 $BRT | "
            [ -n "$BAT" ] && status="$status$BAT | "
            status="$status$TIME $DATE"

            echo "$status"

            iter_count=$((iter_count + 1))
            sleep 2
        done
      '';
      executable = true;
    };

    # Wallpaper - user provides their own at ~/.config/wallpaper.png
    # Default: solid color fallback via swaybg
    home.file.".config/wallpaper.png".text = "";  # Empty placeholder

    # Environment variables
    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "dwl";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "dwl";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    # Home packages for DWL
    home.packages = with pkgs; [
      # Wayland tools
      wl-clipboard
      wlr-randr
      wayland-utils

      # Launchers
      dmenu-wayland
      bemenu

      # Lock screen
      swaylock

      # Screenshots (using grim/slurp for Wayland)
      grim
      slurp

      # Clipboard manager
      wl-clip-persist

      # Widget system for status bar
      eww
    ];

    # Systemd user services for session locking
    systemd.user.services.swayidle-lock-handler = {
      Unit = {
        Description = "Lock screen on system events";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "lock-handler" ''
          # Listen for systemd-logind PrepareForShutdown signal
          # and lock the screen before shutdown/restart
          ${pkgs.systemd}/bin/busctl monitor \
            --user \
            org.freedesktop.login1 \
            /org/freedesktop/login1 \
            org.freedesktop.login1.Manager \
            PrepareForShutdown | \
          while read -r line; do
            if echo "$line" | grep -q "PrepareForShutdown"; then
              # Lock the screen immediately
              ${pkgs.systemd}/bin/loginctl lock-session
            fi
          done
        ''}";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
