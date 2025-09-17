{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.hardware.thermal;

  # Thermal monitoring script for GPD Pocket 3
  thermal-monitor-script = pkgs.writeShellScriptBin "thermal-monitor-gpd" ''
    #!/bin/bash

    # Thermal monitoring and management for GPD Pocket 3
    # Provides emergency protection and thermal event logging

    TEMP_FILE="/sys/class/thermal/thermal_zone0/temp"
    EMERGENCY_TEMP=${toString (cfg.emergencyShutdownTemp * 1000)}
    THROTTLE_TEMP=${toString (cfg.throttleTemp * 1000)}
    CRITICAL_TEMP=${toString (cfg.criticalTemp * 1000)}
    LOG_FILE="/var/log/thermal-monitor.log"
    PID_FILE="/var/run/thermal-monitor.pid"

    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"

    # Create PID file
    echo $$ > "$PID_FILE"

    log_event() {
        local level="$1"
        local message="$2"
        local timestamp=$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] [$level] $message" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"

        # Also log to journal
        ${pkgs.systemd}/bin/systemd-cat -t thermal-monitor -p "$level" echo "$message"
    }

    get_cpu_temp() {
        if [ -f "$TEMP_FILE" ]; then
            cat "$TEMP_FILE"
        else
            echo "0"
        fi
    }

    get_all_temps() {
        local temps=""
        for zone in /sys/class/thermal/thermal_zone*/temp; do
            if [ -f "$zone" ]; then
                local temp=$(cat "$zone")
                local zone_name=$(basename "$(dirname "$zone")")
                temps="$temps $zone_name:$(($temp / 1000))°C"
            fi
        done
        echo "$temps"
    }

    emergency_shutdown() {
        log_event "emerg" "EMERGENCY: CPU temperature reached emergency threshold! Initiating immediate shutdown."
        log_event "emerg" "Current temperatures: $(get_all_temps)"

        # Force immediate shutdown to prevent hardware damage
        ${pkgs.systemd}/bin/systemctl poweroff --force
    }

    critical_throttle() {
        log_event "crit" "CRITICAL: CPU temperature exceeded critical threshold. Applying emergency throttling."
        log_event "crit" "Current temperatures: $(get_all_temps)"

        # Set CPU to minimum frequency
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
            if [ -f "$cpu" ]; then
                local min_freq=$(cat "$(dirname "$cpu")/scaling_min_freq")
                echo "$min_freq" > "$cpu" 2>/dev/null || true
            fi
        done

        # Set CPU governor to powersave
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            if [ -f "$cpu" ]; then
                echo "powersave" > "$cpu" 2>/dev/null || true
            fi
        done
    }

    apply_throttle() {
        log_event "warning" "CPU temperature exceeded throttle threshold. Applying thermal throttling."
        log_event "info" "Current temperatures: $(get_all_temps)"

        # Reduce CPU frequency to 75% of maximum
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
            if [ -f "$cpu" ]; then
                local max_freq=$(cat "$(dirname "$cpu")/cpufreq_max_freq" 2>/dev/null || cat "$(dirname "$cpu")/scaling_max_freq")
                local throttled_freq=$(($max_freq * 3 / 4))
                echo "$throttled_freq" > "$cpu" 2>/dev/null || true
            fi
        done

        # Set CPU governor to conservative
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            if [ -f "$cpu" ]; then
                echo "conservative" > "$cpu" 2>/dev/null || true
            fi
        done
    }

    restore_performance() {
        log_event "info" "Temperature normalized. Restoring performance settings."

        # Restore maximum CPU frequency
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
            if [ -f "$cpu" ]; then
                local max_freq=$(cat "$(dirname "$cpu")/cpufreq_max_freq" 2>/dev/null || echo "999999999")
                echo "$max_freq" > "$cpu" 2>/dev/null || true
            fi
        done

        # Restore CPU governor based on configuration
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            if [ -f "$cpu" ]; then
                echo "${cfg.normalGovernor}" > "$cpu" 2>/dev/null || true
            fi
        done
    }

    cleanup() {
        log_event "info" "Thermal monitor stopped"
        rm -f "$PID_FILE"
        exit 0
    }

    # Set up signal handlers
    trap cleanup EXIT INT TERM

    log_event "info" "Starting thermal monitor for GPD Pocket 3"
    log_event "info" "Thresholds: Throttle=${cfg.throttleTemp}°C, Critical=${cfg.criticalTemp}°C, Emergency=${cfg.emergencyShutdownTemp}°C"

    # State tracking
    throttle_active=false
    critical_active=false
    last_temp=0
    stable_count=0

    while true; do
        current_temp=$(get_cpu_temp)
        current_temp_c=$(($current_temp / 1000))

        # Emergency shutdown check (highest priority)
        if [ "$current_temp" -ge "$EMERGENCY_TEMP" ]; then
            emergency_shutdown
        fi

        # Critical temperature handling
        if [ "$current_temp" -ge "$CRITICAL_TEMP" ]; then
            if [ "$critical_active" = false ]; then
                critical_throttle
                critical_active=true
                throttle_active=true
            fi
        elif [ "$current_temp" -ge "$THROTTLE_TEMP" ]; then
            if [ "$throttle_active" = false ]; then
                apply_throttle
                throttle_active=true
            fi
        else
            # Temperature is below throttle threshold
            if [ "$throttle_active" = true ]; then
                # Wait for temperature to be stable before restoring performance
                if [ "$current_temp" -lt $(($THROTTLE_TEMP - 5000)) ]; then
                    stable_count=$((stable_count + 1))
                    if [ "$stable_count" -ge 6 ]; then  # 30 seconds of stable temperature
                        restore_performance
                        throttle_active=false
                        critical_active=false
                        stable_count=0
                    fi
                else
                    stable_count=0
                fi
            fi
        fi

        # Log temperature every minute if monitoring is enabled
        if [ "${toString cfg.enableDetailedLogging}" = "1" ]; then
            log_event "debug" "CPU temp: ''${current_temp_c}°C, All temps: $(get_all_temps)"
        fi

        last_temp=$current_temp
        ${pkgs.coreutils}/bin/sleep ${toString cfg.monitorInterval}
    done
  '';

  # Fan control script (if fan control is enabled)
  fan-control-script = pkgs.writeShellScriptBin "fan-control-gpd" ''
    #!/bin/bash

    # Fan control for GPD Pocket 3
    # Note: This is hardware-dependent and may not work on all units

    TEMP_FILE="/sys/class/thermal/thermal_zone0/temp"
    LOG_FILE="/var/log/fan-control.log"

    log_event() {
        local message="$1"
        local timestamp=$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] $message" | ${pkgs.coreutils}/bin/tee -a "$LOG_FILE"
    }

    set_fan_speed() {
        local speed_percent="$1"

        # Try to find PWM control for fan
        for pwm in /sys/class/hwmon/hwmon*/pwm*; do
            if [ -f "$pwm" ]; then
                local max_pwm=255
                local target_pwm=$((max_pwm * speed_percent / 100))
                echo "$target_pwm" > "$pwm" 2>/dev/null && {
                    log_event "Set fan speed to $speed_percent% (PWM: $target_pwm)"
                    return 0
                }
            fi
        done

        log_event "Warning: Could not set fan speed - no PWM control found"
        return 1
    }

    get_cpu_temp() {
        if [ -f "$TEMP_FILE" ]; then
            echo $(( $(cat "$TEMP_FILE") / 1000 ))
        else
            echo "0"
        fi
    }

    log_event "Starting fan control for GPD Pocket 3"

    while true; do
        temp=$(get_cpu_temp)

        # Fan curve based on temperature
        if [ "$temp" -ge ${toString cfg.criticalTemp} ]; then
            set_fan_speed 100  # Maximum cooling
        elif [ "$temp" -ge ${toString cfg.throttleTemp} ]; then
            set_fan_speed 80   # High cooling
        elif [ "$temp" -ge 65 ]; then
            set_fan_speed 60   # Moderate cooling
        elif [ "$temp" -ge 55 ]; then
            set_fan_speed 40   # Light cooling
        elif [ "$temp" -ge 45 ]; then
            set_fan_speed 20   # Minimal cooling
        else
            set_fan_speed 10   # Idle speed
        fi

        ${pkgs.coreutils}/bin/sleep ${toString cfg.fanControlInterval}
    done
  '';
in
{
  options.custom.system.hardware.thermal = {
    enable = mkEnableOption "comprehensive thermal management for GPD Pocket 3";

    emergencyShutdownTemp = mkOption {
      type = types.int;
      default = 95;
      description = "Emergency shutdown temperature in Celsius (immediate poweroff to prevent hardware damage)";
    };

    criticalTemp = mkOption {
      type = types.int;
      default = 90;
      description = "Critical temperature in Celsius (emergency throttling)";
    };

    throttleTemp = mkOption {
      type = types.int;
      default = 85;
      description = "Throttling temperature in Celsius (reduce performance)";
    };

    normalGovernor = mkOption {
      type = types.enum [ "performance" "powersave" "ondemand" "conservative" "schedutil" ];
      default = "schedutil";
      description = "CPU governor to use under normal temperature conditions";
    };

    enableThermald = mkOption {
      type = types.bool;
      default = true;
      description = "Enable thermald service for immediate thermal protection";
    };

    enableMonitoring = mkOption {
      type = types.bool;
      default = true;
      description = "Enable continuous thermal monitoring service";
    };

    monitorInterval = mkOption {
      type = types.int;
      default = 5;
      description = "Temperature monitoring interval in seconds";
    };

    enableDetailedLogging = mkOption {
      type = types.bool;
      default = false;
      description = "Enable detailed temperature logging (warning: generates significant log data)";
    };

    enableFanControl = mkOption {
      type = types.bool;
      default = false;
      description = "Enable fan curve management (experimental - hardware dependent)";
    };

    fanControlInterval = mkOption {
      type = types.int;
      default = 10;
      description = "Fan control update interval in seconds";
    };

    enableSensors = mkOption {
      type = types.bool;
      default = true;
      description = "Enable lm-sensors for temperature monitoring and reporting";
    };
  };

  config = mkIf cfg.enable {
    # Install thermal management packages
    environment.systemPackages = with pkgs; [
      thermal-monitor-script
      lm_sensors    # Temperature monitoring
      stress        # Stress testing
      s-tui         # Terminal UI for system monitoring
      htop          # System monitoring
    ] ++ optionals cfg.enableFanControl [
      fan-control-script
      pwmconfig     # PWM fan configuration
    ];

    # Enable thermald service for immediate thermal protection
    services.thermald = mkIf cfg.enableThermald {
      enable = true;
      # Use default thermal configuration - thermald will automatically
      # detect thermal zones and apply appropriate cooling policies
    };

    # Enable hardware sensors
    hardware.sensor.iio.enable = true;

    # CPU frequency scaling configuration
    powerManagement.cpuFreqGovernor = cfg.normalGovernor;

    # Enable CPU frequency scaling
    boot.kernelModules = [ "acpi-cpufreq" "cpufreq_stats" ];

    # Custom thermal monitoring service
    systemd.services.thermal-monitor = mkIf cfg.enableMonitoring {
      description = "Thermal monitoring and emergency protection for GPD Pocket 3";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${thermal-monitor-script}/bin/thermal-monitor-gpd";
        Restart = "always";
        RestartSec = 10;
        User = "root";  # Required for thermal management

        # Security hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/log" "/var/run" "/sys/devices/system/cpu" ];
        PrivateTmp = true;

        # Resource limits
        MemoryMax = "50M";
        CPUQuota = "10%";
      };
    };

    # Fan control service (optional)
    systemd.services.fan-control = mkIf cfg.enableFanControl {
      description = "Fan curve control for GPD Pocket 3";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${fan-control-script}/bin/fan-control-gpd";
        Restart = "always";
        RestartSec = 15;
        User = "root";  # Required for hardware control

        # Security hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/log" "/sys/class/hwmon" ];
        PrivateTmp = true;

        # Resource limits
        MemoryMax = "30M";
        CPUQuota = "5%";
      };
    };

    # Kernel parameters for thermal management
    boot.kernelParams = [
      # Enable thermal zone monitoring
      "thermal.debug=1"
      # Set thermal polling delay (milliseconds)
      "thermal.polling_delay=1000"
    ];

    # udev rules for thermal management permissions
    services.udev.extraRules = ''
      # Allow thermal monitoring access
      SUBSYSTEM=="thermal", GROUP="wheel", MODE="0664"

      # Allow hwmon access for fan control
      SUBSYSTEM=="hwmon", GROUP="wheel", MODE="0664"

      # Allow CPU frequency scaling access
      SUBSYSTEM=="cpu", ATTR{cpufreq/scaling_governor}=="*", GROUP="wheel", MODE="0664"
      SUBSYSTEM=="cpu", ATTR{cpufreq/scaling_max_freq}=="*", GROUP="wheel", MODE="0664"
    '';

    # Logrotate configuration for thermal logs
    services.logrotate.settings.thermal = {
      files = [ "/var/log/thermal-monitor.log" "/var/log/fan-control.log" ];
      frequency = "daily";
      rotate = 7;
      compress = true;
      delaycompress = true;
      missingok = true;
      notifempty = true;
      create = "644 root root";
    };

    # Ensure log directory exists
    systemd.tmpfiles.rules = [
      "d /var/log 0755 root root -"
    ];

    # Environment variables for thermal monitoring tools
    environment.variables = {
      THERMAL_ZONE = "thermal_zone0";
      THERMAL_LOG_LEVEL = if cfg.enableDetailedLogging then "debug" else "info";
    };

    # Enable lm-sensors detection and configuration
    systemd.services.sensors-detect = mkIf cfg.enableSensors {
      description = "Detect and configure hardware sensors";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.lm_sensors}/bin/sensors-detect --auto";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };
  };
}