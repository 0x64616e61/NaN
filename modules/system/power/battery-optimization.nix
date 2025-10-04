{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.power.battery;
in
{
  options.custom.system.power.battery = {
    enable = mkEnableOption "battery optimization for GPD Pocket 3";

    tlp = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable TLP advanced power management";
      };

      chargeThresholds = {
        startThreshold = mkOption {
          type = types.int;
          default = 20;
          description = "Battery charge start threshold (%)";
        };

        stopThreshold = mkOption {
          type = types.int;
          default = 80;
          description = "Battery charge stop threshold (%)";
        };
      };

      powerProfiles = {
        performance = mkOption {
          type = types.bool;
          default = true;
          description = "Enable performance power profile";
        };

        balanced = mkOption {
          type = types.bool;
          default = true;
          description = "Enable balanced power profile";
        };

        powerSave = mkOption {
          type = types.bool;
          default = true;
          description = "Enable power save profile";
        };
      };

      cpuGovernor = {
        onAC = mkOption {
          type = types.enum [ "performance" "powersave" ];
          default = "performance";
          description = "CPU governor when on AC power";
        };

        onBattery = mkOption {
          type = types.enum [ "performance" "powersave" ];
          default = "powersave";
          description = "CPU governor when on battery";
        };
      };

      intelCpuSettings = {
        enablePstates = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Intel P-states for i3-1125G4";
        };

        enableTurboBoost = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Intel Turbo Boost on AC";
        };

        disableTurboOnBattery = mkOption {
          type = types.bool;
          default = true;
          description = "Disable Turbo Boost on battery to save power";
        };

        minFreqPercent = mkOption {
          type = types.int;
          default = 0;
          description = "Minimum CPU frequency percentage";
        };

        maxFreqPercentAC = mkOption {
          type = types.int;
          default = 100;
          description = "Maximum CPU frequency percentage on AC";
        };

        maxFreqPercentBattery = mkOption {
          type = types.int;
          default = 60;  # AGGRESSIVE: Maximum battery savings (was 75%)
          description = "Maximum CPU frequency percentage on battery";
        };
      };
    };

    monitoring = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable battery health monitoring";
      };

      enableUpower = mkOption {
        type = types.bool;
        default = true;
        description = "Enable UPower for battery statistics";
      };

      enableAcpi = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ACPI tools for battery info";
      };

      enablePowerTop = mkOption {
        type = types.bool;
        default = true;  # Enabled for ongoing monitoring and tuning
        description = "Enable PowerTOP for power analysis";
      };

      alertThresholds = {
        lowBattery = mkOption {
          type = types.int;
          default = 15;
          description = "Low battery warning threshold (%)";
        };

        criticalBattery = mkOption {
          type = types.int;
          default = 5;
          description = "Critical battery threshold (%)";
        };
      };
    };

    additionalOptimizations = {
      enableAutoCpufreq = mkOption {
        type = types.bool;
        default = false;
        description = "Enable auto-cpufreq (alternative to TLP, mutually exclusive)";
      };

      disableWakeOnLan = mkOption {
        type = types.bool;
        default = true;
        description = "Disable Wake-on-LAN to save power";
      };

      enableWifiPowerSave = mkOption {
        type = types.bool;
        default = true;
        description = "Enable WiFi power saving";
      };

      reduceSwappiness = mkOption {
        type = types.bool;
        default = true;
        description = "Reduce swappiness to minimize disk usage";
      };

      enableKernelPowerSaving = mkOption {
        type = types.bool;
        default = true;
        description = "Enable various kernel power saving features";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Core TLP configuration
    (mkIf cfg.tlp.enable {
      services.tlp = {
        enable = true;
        settings = {
          # Battery charge thresholds
          START_CHARGE_THRESH_BAT0 = cfg.tlp.chargeThresholds.startThreshold;
          STOP_CHARGE_THRESH_BAT0 = cfg.tlp.chargeThresholds.stopThreshold;

          # CPU scaling governor
          CPU_SCALING_GOVERNOR_ON_AC = cfg.tlp.cpuGovernor.onAC;
          CPU_SCALING_GOVERNOR_ON_BAT = cfg.tlp.cpuGovernor.onBattery;

          # REMOVED PROBLEMATIC FREQUENCY SETTINGS
          # CPU frequency scaling is now handled by governors only
          # This prevents invalid frequency values from causing boot failures

          # Intel CPU energy performance preferences
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

          # Intel Turbo Boost
          CPU_BOOST_ON_AC = if cfg.tlp.intelCpuSettings.enableTurboBoost then 1 else 0;
          CPU_BOOST_ON_BAT = if cfg.tlp.intelCpuSettings.disableTurboOnBattery then 0 else 1;

          # Intel HWP (Hardware P-states) for Tiger Lake
          CPU_HWP_DYN_BOOST_ON_AC = 1;
          CPU_HWP_DYN_BOOST_ON_BAT = 0;

          # Platform profile for modern Intel CPUs
          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";

          # PCI Express power management
          PCIE_ASPM_ON_AC = "default";
          PCIE_ASPM_ON_BAT = "powersupersave";

          # WiFi power saving (Intel AX201 common in Tiger Lake)
          WIFI_PWR_ON_AC = "off";
          WIFI_PWR_ON_BAT = "on";

          # AGGRESSIVE BATTERY SAVINGS
          # Reduce screen brightness impact
          INTEL_GPU_MIN_FREQ_ON_BAT = 300;
          INTEL_GPU_MAX_FREQ_ON_BAT = 800;
          INTEL_GPU_BOOST_FREQ_ON_BAT = 800;

          # Audio power saving
          SOUND_POWER_SAVE_ON_AC = 0;
          SOUND_POWER_SAVE_ON_BAT = 1;
          SOUND_POWER_SAVE_CONTROLLER = "Y";

          # USB power management
          USB_AUTOSUSPEND = 1;
          USB_EXCLUDE_AUDIO = 1;
          USB_EXCLUDE_BTUSB = 0;
          USB_EXCLUDE_PHONE = 0;
          USB_EXCLUDE_PRINTER = 1;
          USB_EXCLUDE_WWAN = 0;

          # Runtime power management - AGGRESSIVE
          RUNTIME_PM_ON_AC = "on";
          RUNTIME_PM_ON_BAT = "auto";

          # Aggressive device autosuspend
          RUNTIME_PM_DRIVER_DENYLIST = "";
          RUNTIME_PM_ALL = 1;

          # SATA link power management
          SATA_LINKPWR_ON_AC = "med_power_with_dipm";
          SATA_LINKPWR_ON_BAT = "min_power";

          # Disk power management - AGGRESSIVE
          DISK_APM_LEVEL_ON_AC = "254";
          DISK_APM_LEVEL_ON_BAT = "64";  # More aggressive (was 128)
          DISK_SPINDOWN_TIMEOUT_ON_AC = "0";
          DISK_SPINDOWN_TIMEOUT_ON_BAT = "6";  # Faster spindown (was 12)

          # Radios (Bluetooth, WiFi, WWAN)
          RESTORE_DEVICE_STATE_ON_STARTUP = 0;
          DEVICES_TO_DISABLE_ON_STARTUP = "";
          DEVICES_TO_ENABLE_ON_STARTUP = "wifi bluetooth";
          DEVICES_TO_DISABLE_ON_SHUTDOWN = "";
          DEVICES_TO_ENABLE_ON_SHUTDOWN = "";
          DEVICES_TO_ENABLE_ON_AC = "";
          DEVICES_TO_DISABLE_ON_BAT = "";
          DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "";

          # Battery care settings
          NATACPI_ENABLE = 1;
          TPACPI_ENABLE = 1;
          TPSMAPI_ENABLE = 1;
        };
      };

      # Conflict resolution: disable other power management if TLP is enabled
      powerManagement.powertop.enable = mkForce false;
      services.auto-cpufreq.enable = mkForce false;
      services.power-profiles-daemon.enable = mkForce false;
    })

    # Auto-cpufreq as alternative to TLP
    (mkIf (cfg.additionalOptimizations.enableAutoCpufreq && !cfg.tlp.enable) {
      services.auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = cfg.tlp.cpuGovernor.onBattery;
            turbo = if cfg.tlp.intelCpuSettings.disableTurboOnBattery then "never" else "auto";
          };
          charger = {
            governor = cfg.tlp.cpuGovernor.onAC;
            turbo = if cfg.tlp.intelCpuSettings.enableTurboBoost then "auto" else "never";
          };
        };
      };

      # Disable conflicting services
      services.tlp.enable = mkForce false;
      services.power-profiles-daemon.enable = mkForce false;
    })

    # Battery monitoring tools
    (mkIf cfg.monitoring.enable {
      # UPower for battery statistics
      services.upower = mkIf cfg.monitoring.enableUpower {
        enable = true;
        percentageLow = cfg.monitoring.alertThresholds.lowBattery;
        percentageCritical = cfg.monitoring.alertThresholds.criticalBattery;
        percentageAction = cfg.monitoring.alertThresholds.criticalBattery;
        criticalPowerAction = "Suspend";
        allowRiskyCriticalPowerAction = true;
      };

      # System packages for monitoring
      environment.systemPackages = with pkgs; [
        (mkIf cfg.monitoring.enableAcpi acpi)
        (mkIf cfg.monitoring.enablePowerTop powertop)
        (mkIf cfg.tlp.enable tlp)
        # Battery health monitoring tools
        upower
        lm_sensors
        cpufrequtils
        cpupower-gui
        # Intel-specific tools
        intel-gpu-tools
      ];
    })

    # Additional optimizations
    (mkIf cfg.additionalOptimizations.enableKernelPowerSaving {
      # Kernel parameters for power saving
      boot.kernelParams = [
        # Intel i915 graphics power saving
        "i915.enable_rc6=1"
        "i915.enable_fbc=1"
        "i915.lvds_downclock=1"
        "i915.semaphores=1"

        # ACPI and power management
        "acpi_osi=Linux"
        "acpi_backlight=vendor"

        # Disable unnecessary hardware
        "modprobe.blacklist=pcspkr"

        # NMI watchdog (saves power)
        "nmi_watchdog=0"

        # Enable ASPM (might be overridden by TLP)
        "pcie_aspm=force"
      ];

      # Kernel modules
      boot.kernelModules = [
        "acpi_cpufreq"  # CPU frequency scaling
        "cpufreq_powersave"
        "cpufreq_conservative"
        "cpufreq_ondemand"
      ];
    })

    # Network power optimizations
    (mkIf cfg.additionalOptimizations.enableWifiPowerSave {
      # WiFi power management using kernel modules
      boot.extraModprobeConfig = ''
        # Enable WiFi power saving
        options iwlwifi power_save=1
        options iwldvm force_cam=0
      '';
    })

    # Swappiness optimization
    (mkIf cfg.additionalOptimizations.reduceSwappiness {
      boot.kernel.sysctl = {
        "vm.swappiness" = 1;  # Minimize swap usage (was 10)
        "vm.dirty_ratio" = 10;  # Minimize disk writes (was 15)
        "vm.dirty_background_ratio" = 3;  # Aggressive writeback (was 5)
        "vm.laptop_mode" = 5;  # Enable laptop mode for disk power savings
      };
    })

    # Wake-on-LAN disable
    (mkIf cfg.additionalOptimizations.disableWakeOnLan {
      systemd.services.disable-wol = {
        description = "Disable Wake-on-LAN";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp0s3 wol d || true";
        };
      };
    })

    # Systemd optimizations for better power management
    {
      systemd.settings = {
        Manager = {
          DefaultTimeoutStopSec = "30s";
          DefaultTimeoutStartSec = "30s";
        };
      };

      # Power button handling
      services.logind.settings = {
        Login = {
          HandlePowerKey = "suspend";
          PowerKeyIgnoreInhibited = "no";
        };
      };

      # Tmpfs optimizations to reduce disk writes
      fileSystems."/tmp" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [ "defaults" "size=2G" "mode=1777" ];
      };
    }

    # Create battery monitoring scripts
    (mkIf cfg.monitoring.enable {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "battery-status" ''
          #!/bin/bash
          echo "=== Battery Status ==="
          ${pkgs.acpi}/bin/acpi -b
          echo ""
          echo "=== Power Profile ==="
          ${pkgs.tlp}/bin/tlp-stat -s 2>/dev/null || echo "TLP not running"
          echo ""
          echo "=== CPU Governor ==="
          cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A"
          echo ""
          echo "=== CPU Frequency ==="
          cat /proc/cpuinfo | grep "cpu MHz" | head -4
          echo ""
          echo "=== Battery Health ==="
          ${pkgs.upower}/bin/upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null || echo "Battery info not available"
        '')

        (pkgs.writeShellScriptBin "power-profile" ''
          #!/bin/bash
          case "$1" in
            performance)
              echo "Switching to performance mode..."
              ${optionalString cfg.tlp.enable "${pkgs.tlp}/bin/tlp ac"}
              ;;
            powersave)
              echo "Switching to power save mode..."
              ${optionalString cfg.tlp.enable "${pkgs.tlp}/bin/tlp bat"}
              ;;
            *)
              echo "Usage: power-profile [performance|powersave]"
              echo "Current status:"
              ${optionalString cfg.tlp.enable "${pkgs.tlp}/bin/tlp-stat -s"}
              ;;
          esac
        '')
      ];
    })
  ]);
}