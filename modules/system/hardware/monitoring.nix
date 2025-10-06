{ config, lib, pkgs, ... }:
# GPD Pocket 3 Hardware Monitoring Module
#
# This module provides comprehensive hardware health monitoring for the GPD Pocket 3,
# tracking temperatures, fan speeds, battery status, and storage health.
#
# Features:
# - CPU/GPU temperature monitoring via hwmon sensors
# - Fan speed tracking and alerts
# - Battery health and charge status monitoring
# - NVMe/SSD storage health via SMART
# - Configurable alert thresholds and notification methods
#
# Configuration:
#   custom.system.hardware.monitoring = {
#     enable = true;
#     checkInterval = 60;  # seconds
#     alerts.method = "all";  # notify | systemd | log | all
#   };
#
# Complexity: 535 lines (consider refactoring into sub-modules)

with lib;

let
  cfg = config.custom.system.hardware.monitoring;

  # Hardware monitoring script for GPD Pocket 3
  # This script runs as a systemd service, periodically checking hardware health
  # and sending alerts when thresholds are exceeded
  monitor-script = pkgs.writeShellScriptBin "gpd-hardware-monitor" ''
    #!/bin/bash

    # Hardware monitoring for GPD Pocket 3
    # Monitors temperatures, fan speeds, battery, and storage health

    set -euo pipefail

    # Configuration
    TEMP_HIGH_THRESHOLD=${toString cfg.alerts.temperatureHigh}
    BATTERY_LOW_THRESHOLD=${toString cfg.alerts.batteryLow}
    LOG_FILE="${cfg.logging.logFile}"
    LOG_LEVEL="${cfg.logging.level}"
    ALERT_METHOD="${cfg.alerts.method}"
    CHECK_INTERVAL=${toString cfg.checkInterval}

    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"

    # Logging functions
    log_message() {
        local level="$1"
        local message="$2"
        local timestamp=$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')

        case "$LOG_LEVEL" in
            "debug") echo "[$timestamp] [$level] $message" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE" ;;
            "info")
                if [[ "$level" != "DEBUG" ]]; then
                    echo "[$timestamp] [$level] $message" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"
                fi ;;
            "warn")
                if [[ "$level" == "WARN" || "$level" == "ERROR" || "$level" == "CRITICAL" ]]; then
                    echo "[$timestamp] [$level] $message" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"
                fi ;;
            "error")
                if [[ "$level" == "ERROR" || "$level" == "CRITICAL" ]]; then
                    echo "[$timestamp] [$level] $message" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"
                fi ;;
        esac
    }

    # Alert notification function
    send_alert() {
        local severity="$1"
        local message="$2"

        log_message "$severity" "$message"

        case "$ALERT_METHOD" in
            "notify")
                if command -v ${pkgs.libnotify}/bin/notify-send >/dev/null 2>&1; then
                    ${pkgs.libnotify}/bin/notify-send -u critical "Hardware Alert" "$message"
                fi ;;
            "systemd")
                ${pkgs.systemd}/bin/systemd-cat -t "gpd-hardware-monitor" -p "$severity" echo "$message" ;;
            "log")
                # Already logged above
                ;;
            "all")
                if command -v ${pkgs.libnotify}/bin/notify-send >/dev/null 2>&1; then
                    ${pkgs.libnotify}/bin/notify-send -u critical "Hardware Alert" "$message"
                fi
                ${pkgs.systemd}/bin/systemd-cat -t "gpd-hardware-monitor" -p "$severity" echo "$message"
                ;;
        esac
    }

    # Temperature monitoring
    check_temperatures() {
        log_message "DEBUG" "Checking CPU/GPU temperatures"

        # Initialize sensors if available
        if command -v ${pkgs.lm_sensors}/bin/sensors-detect >/dev/null 2>&1; then
            ${pkgs.lm_sensors}/bin/sensors >/dev/null 2>&1 || true
        fi

        # Check CPU temperature via hwmon
        local cpu_temp=""
        local gpu_temp=""

        # Try different hwmon paths for CPU temperature
        for hwmon in /sys/class/hwmon/hwmon*; do
            if [[ -f "$hwmon/name" ]]; then
                local sensor_name=$(cat "$hwmon/name")
                case "$sensor_name" in
                    "coretemp"|"k10temp"|"zenpower")
                        if [[ -f "$hwmon/temp1_input" ]]; then
                            cpu_temp=$(($(cat "$hwmon/temp1_input") / 1000))
                            log_message "DEBUG" "CPU temperature: ''${cpu_temp}°C (sensor: $sensor_name)"
                            break
                        fi ;;
                esac
            fi
        done

        # Try ACPI thermal zones as fallback
        if [[ -z "$cpu_temp" ]]; then
            for thermal in /sys/class/thermal/thermal_zone*; do
                if [[ -f "$thermal/temp" ]]; then
                    local temp=$(($(cat "$thermal/temp") / 1000))
                    if [[ $temp -gt 0 && $temp -lt 200 ]]; then  # Reasonable temperature range
                        cpu_temp=$temp
                        log_message "DEBUG" "CPU temperature: ''${cpu_temp}°C (thermal zone)"
                        break
                    fi
                fi
            done
        fi

        # Check GPU temperature (Intel integrated graphics)
        for hwmon in /sys/class/hwmon/hwmon*; do
            if [[ -f "$hwmon/name" ]]; then
                local sensor_name=$(cat "$hwmon/name")
                if [[ "$sensor_name" == "i915" ]]; then
                    if [[ -f "$hwmon/temp1_input" ]]; then
                        gpu_temp=$(($(cat "$hwmon/temp1_input") / 1000))
                        log_message "DEBUG" "GPU temperature: ''${gpu_temp}°C"
                        break
                    fi
                fi
            fi
        done

        # Check temperature alerts
        if [[ -n "$cpu_temp" ]] && [[ $cpu_temp -ge $TEMP_HIGH_THRESHOLD ]]; then
            send_alert "CRITICAL" "CPU temperature critical: ''${cpu_temp}°C (threshold: ''${TEMP_HIGH_THRESHOLD}°C)"
        fi

        if [[ -n "$gpu_temp" ]] && [[ $gpu_temp -ge $TEMP_HIGH_THRESHOLD ]]; then
            send_alert "CRITICAL" "GPU temperature critical: ''${gpu_temp}°C (threshold: ''${TEMP_HIGH_THRESHOLD}°C)"
        fi

        # Return temperatures for status display
        echo "CPU_TEMP=$cpu_temp"
        echo "GPU_TEMP=$gpu_temp"
    }

    # Fan speed monitoring
    check_fan_speeds() {
        log_message "DEBUG" "Checking fan speeds"

        local fan_speed=""

        # Check for fan sensors in hwmon
        for hwmon in /sys/class/hwmon/hwmon*; do
            if [[ -f "$hwmon/fan1_input" ]]; then
                fan_speed=$(cat "$hwmon/fan1_input")
                log_message "DEBUG" "Fan speed: ''${fan_speed} RPM"
                break
            fi
        done

        # Check ACPI fan status as fallback
        if [[ -z "$fan_speed" ]] && [[ -d "/proc/acpi/fan" ]]; then
            for fan_dir in /proc/acpi/fan/*/; do
                if [[ -f "$fan_dir/state" ]]; then
                    local fan_state=$(cat "$fan_dir/state")
                    log_message "DEBUG" "Fan state: $fan_state"
                fi
            done
        fi

        echo "FAN_SPEED=$fan_speed"
    }

    # Battery health monitoring
    check_battery() {
        log_message "DEBUG" "Checking battery status"

        local battery_level=""
        local battery_status=""
        local battery_health=""

        # Check battery via sysfs
        for battery in /sys/class/power_supply/BAT*; do
            if [[ -d "$battery" ]]; then
                if [[ -f "$battery/capacity" ]]; then
                    battery_level=$(cat "$battery/capacity")
                fi
                if [[ -f "$battery/status" ]]; then
                    battery_status=$(cat "$battery/status")
                fi
                if [[ -f "$battery/health" ]]; then
                    battery_health=$(cat "$battery/health")
                fi
                break
            fi
        done

        # Try ACPI as fallback
        if [[ -z "$battery_level" ]] && command -v ${pkgs.acpi}/bin/acpi >/dev/null 2>&1; then
            local acpi_output=$(${pkgs.acpi}/bin/acpi -b 2>/dev/null || true)
            if [[ -n "$acpi_output" ]]; then
                battery_level=$(echo "$acpi_output" | ${pkgs.gnugrep}/bin/grep -oP '\d+(?=%)' | head -1)
                battery_status=$(echo "$acpi_output" | ${pkgs.gnugrep}/bin/grep -oP '(Charging|Discharging|Full|Unknown)' | head -1)
            fi
        fi

        log_message "DEBUG" "Battery: ''${battery_level}% (''${battery_status}) Health: ''${battery_health}"

        # Check battery alerts
        if [[ -n "$battery_level" ]] && [[ $battery_level -le $BATTERY_LOW_THRESHOLD ]] && [[ "$battery_status" == "Discharging" ]]; then
            send_alert "WARN" "Battery level low: ''${battery_level}% (threshold: ''${BATTERY_LOW_THRESHOLD}%)"
        fi

        echo "BATTERY_LEVEL=$battery_level"
        echo "BATTERY_STATUS=$battery_status"
        echo "BATTERY_HEALTH=$battery_health"
    }

    # Storage health monitoring
    check_storage() {
        log_message "DEBUG" "Checking storage health"

        # Get all block devices
        for device in $(${pkgs.util-linux}/bin/lsblk -dno NAME | ${pkgs.gnugrep}/bin/grep -E '^(sd|nvme|mmc)'); do
            local device_path="/dev/$device"

            # Skip if device doesn't exist
            [[ -b "$device_path" ]] || continue

            log_message "DEBUG" "Checking storage device: $device_path"

            # Check SMART status if available
            if command -v ${pkgs.smartmontools}/bin/smartctl >/dev/null 2>&1; then
                local smart_output=$(${pkgs.smartmontools}/bin/smartctl -H "$device_path" 2>/dev/null || true)
                if [[ -n "$smart_output" ]]; then
                    if echo "$smart_output" | ${pkgs.gnugrep}/bin/grep -q "PASSED"; then
                        log_message "DEBUG" "SMART status for $device: PASSED"
                    elif echo "$smart_output" | ${pkgs.gnugrep}/bin/grep -q "FAILED"; then
                        send_alert "CRITICAL" "SMART status for $device: FAILED"
                    fi
                fi

                # Check temperature for NVMe drives
                if [[ "$device" =~ ^nvme ]]; then
                    local nvme_temp=$(${pkgs.smartmontools}/bin/smartctl -a "$device_path" 2>/dev/null | \
                        ${pkgs.gnugrep}/bin/grep -oP 'Temperature:\s+\K\d+' || echo "")
                    if [[ -n "$nvme_temp" ]]; then
                        log_message "DEBUG" "NVMe temperature for $device: ''${nvme_temp}°C"
                        if [[ $nvme_temp -ge 70 ]]; then  # NVMe thermal throttling threshold
                            send_alert "WARN" "NVMe temperature high for $device: ''${nvme_temp}°C"
                        fi
                    fi
                fi
            fi
        done
    }

    # Main monitoring loop
    run_monitoring() {
        log_message "INFO" "Starting hardware monitoring for GPD Pocket 3"

        while true; do
            {
                check_temperatures
                check_fan_speeds
                check_battery
                check_storage
                echo "LAST_CHECK=$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')"
            } > /tmp/gpd-hardware-status

            ${pkgs.coreutils}/bin/sleep "$CHECK_INTERVAL"
        done
    }

    # Handle script arguments
    case "''${1:-monitor}" in
        "monitor")
            run_monitoring ;;
        "status")
            if [[ -f /tmp/gpd-hardware-status ]]; then
                cat /tmp/gpd-hardware-status
            else
                echo "No monitoring data available"
                exit 1
            fi ;;
        "test")
            log_message "INFO" "Running hardware monitoring test"
            check_temperatures
            check_fan_speeds
            check_battery
            check_storage
            log_message "INFO" "Hardware monitoring test completed" ;;
        *)
            echo "Usage: $0 {monitor|status|test}"
            echo "  monitor - Start continuous monitoring (default)"
            echo "  status  - Show current hardware status"
            echo "  test    - Run one-time hardware check"
            exit 1 ;;
    esac
  '';

  # Status display script
  status-script = pkgs.writeShellScriptBin "gpd-hardware-status" ''
    #!/bin/bash

    # Display hardware status in human-readable format

    if [[ ! -f /tmp/gpd-hardware-status ]]; then
        echo "Hardware monitoring not running or no data available"
        echo "Start monitoring with: systemctl --user start gpd-hardware-monitor"
        exit 1
    fi

    source /tmp/gpd-hardware-status

    echo "=== GPD Pocket 3 Hardware Status ==="
    echo "Last Check: $LAST_CHECK"
    echo ""

    echo "Temperatures:"
    if [[ -n "$CPU_TEMP" ]]; then
        echo "  CPU: ''${CPU_TEMP}°C"
    else
        echo "  CPU: Not available"
    fi

    if [[ -n "$GPU_TEMP" ]]; then
        echo "  GPU: ''${GPU_TEMP}°C"
    else
        echo "  GPU: Not available"
    fi
    echo ""

    echo "Fan:"
    if [[ -n "$FAN_SPEED" ]]; then
        echo "  Speed: ''${FAN_SPEED} RPM"
    else
        echo "  Speed: Not available"
    fi
    echo ""

    echo "Battery:"
    if [[ -n "$BATTERY_LEVEL" ]]; then
        echo "  Level: ''${BATTERY_LEVEL}%"
        echo "  Status: ''${BATTERY_STATUS:-Unknown}"
        if [[ -n "$BATTERY_HEALTH" ]]; then
            echo "  Health: $BATTERY_HEALTH"
        fi
    else
        echo "  Status: Not available"
    fi
    echo ""

    echo "Alerts:"
    local alert_count=$(${pkgs.gnugrep}/bin/grep -c "WARN\|CRITICAL" "${cfg.logging.logFile}" 2>/dev/null || echo "0")
    echo "  Recent alerts: $alert_count (check ${cfg.logging.logFile})"
  '';

in {
  options.custom.system.hardware.monitoring = {
    enable = mkEnableOption "GPD Pocket 3 hardware monitoring";

    checkInterval = mkOption {
      type = types.int;
      default = 30;
      description = "Monitoring check interval in seconds";
    };

    alerts = {
      temperatureHigh = mkOption {
        type = types.int;
        default = 80;
        description = "High temperature alert threshold in Celsius";
      };

      batteryLow = mkOption {
        type = types.int;
        default = 15;
        description = "Low battery alert threshold in percentage";
      };

      method = mkOption {
        type = types.enum [ "notify" "systemd" "log" "all" ];
        default = "all";
        description = "Alert notification method";
      };
    };

    logging = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable logging of monitoring data";
      };

      logFile = mkOption {
        type = types.str;
        default = "/var/log/gpd-hardware-monitor.log";
        description = "Path to log file";
      };

      level = mkOption {
        type = types.enum [ "debug" "info" "warn" "error" ];
        default = "info";
        description = "Logging level";
      };
    };
  };

  config = mkIf cfg.enable {
    # Required packages
    environment.systemPackages = with pkgs; [
      lm_sensors
      smartmontools
      acpi
      libnotify
      monitor-script
      status-script
    ];

    # Enable hardware sensors
    hardware.sensor.iio.enable = true;

    # Kernel modules for sensors
    boot.kernelModules = [ "coretemp" "i915" ];

    # Initialize lm-sensors
    environment.etc."sensors.conf" = {
      text = ''
        # Sensors configuration for GPD Pocket 3

        chip "coretemp-*"
          label temp1 "CPU Temperature"

        chip "i915-*"
          label temp1 "GPU Temperature"
      '';
    };

    # User systemd service for hardware monitoring
    systemd.user.services.gpd-hardware-monitor = {
      description = "GPD Pocket 3 Hardware Monitor";
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${monitor-script}/bin/gpd-hardware-monitor monitor";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "always";
        RestartSec = "10";

        # Security settings
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [
          "/tmp"
          (dirOf cfg.logging.logFile)
        ];

        # Resource limits
        MemoryMax = "50M";
        CPUQuota = "10%";
      };

      environment = {
        PATH = mkDefault "/run/current-system/sw/bin";
      };
    };

    # System timer for periodic health checks
    systemd.timers.gpd-hardware-health-check = mkIf cfg.logging.enable {
      description = "GPD Pocket 3 Hardware Health Check Timer";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "1h";
        Unit = "gpd-hardware-health-check.service";
      };
    };

    systemd.services.gpd-hardware-health-check = mkIf cfg.logging.enable {
      description = "GPD Pocket 3 Hardware Health Check";

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${monitor-script}/bin/gpd-hardware-monitor test";
        User = "root";

        # Security settings
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ReadWritePaths = [
          "/tmp"
          (dirOf cfg.logging.logFile)
        ];
      };

      environment = {
        PATH = mkDefault "/run/current-system/sw/bin";
      };
    };

    # Log rotation
    services.logrotate.settings."${cfg.logging.logFile}" = mkIf cfg.logging.enable {
      frequency = "weekly";
      rotate = 4;
      compress = true;
      delaycompress = true;
      missingok = true;
      notifempty = true;
      create = "644 root root";
      postrotate = ''
        systemctl reload gpd-hardware-monitor || true
      '';
    };

    # Create log directory
    systemd.tmpfiles.rules = mkIf cfg.logging.enable [
      "d ${dirOf cfg.logging.logFile} 0755 root root -"
      "f ${cfg.logging.logFile} 0644 root root -"
    ];

    # Shell aliases for convenience
    environment.shellAliases = {
      hwmon = "${status-script}/bin/gpd-hardware-status";
      hwmon-log = "tail -f ${cfg.logging.logFile}";
      hwmon-test = "${monitor-script}/bin/gpd-hardware-monitor test";
    };
  };
}