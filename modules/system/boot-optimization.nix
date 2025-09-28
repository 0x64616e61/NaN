{ config, lib, pkgs, ... }:

with lib;

{
  # GPD Pocket 3 Boot Speed Optimization Module - REBOOT SAFE ✨
  # Based on SuperClaude UX methodology and handheld device requirements

  # Disable blocking services that cause boot delays
  systemd.services = {
    # NetworkManager wait-online causes 30+ second delays on handheld devices
    NetworkManager-wait-online.enable = false;

    # systemd-resolved timeout optimization
    systemd-resolved = {
      enable = true;
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "2";
        TimeoutStartSec = "15";  # Optimized from default 30s
        MemoryMax = "64M";
        CPUQuota = "20%";
        Environment = [
          "TERM=xterm-256color"
        ];
      };
    };

    # Optimize udev settle time for faster hardware detection
    systemd-udev-settle.enable = false;

    # Enhanced boot completion service - REBOOT SAFE
    gpd-boot-optimizer = {
      enable = true;
      description = "GPD Pocket 3 Boot Optimization Service - Reboot Safe ✨";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "always";
        RestartSec = "3";
        MemoryMax = "128M";
        CPUQuota = "30%";
        Environment = [
          "TERM=xterm-256color"
          "PATH=/run/current-system/sw/bin"
        ];
        ExecStart = pkgs.writeShellScript "gpd-boot-optimize" ''
          sys="coreutils systemd hyprland"
          nix-shell -p $sys --run '
            echo "$(date): 🚀 GPD Boot Optimization Starting... (◕‿◕)"

            # Log boot completion time with kaomoji
            echo "$(date): ✨ GPD Boot completed successfully! ＼(^o^)／" > /tmp/gpd-boot-complete

            # Ensure rotation service starts immediately
            systemctl --user restart gpd-iio-rotation 2>/dev/null || echo "$(date): ⚠️ Rotation service not found"

            # Pre-warm frequently used applications
            systemctl --user start waybar 2>/dev/null || echo "$(date): ⚠️ Waybar not available"

            echo "$(date): 🎯 Boot optimization complete ✨"
          '
        '';
      };
    };
  };

  # Boot loader optimization for handheld devices
  boot = {
    # Limit boot menu timeout for faster startup
    loader = {
      timeout = 2;  # 2 second boot menu (optimized for handheld use)

      # Limit stored configurations to save space and boot time
      systemd-boot.configurationLimit = 8;  # Keep 8 generations for recovery
      grub.configurationLimit = 8;
    };

    # Kernel optimization for GPD Pocket 3 - Enhanced
    kernelParams = [
      "quiet"           # Reduce boot messages for faster perceived boot
      "loglevel=3"      # Minimize kernel logging overhead
      "rd.udev.log_level=3"  # Reduce udev logging
      "systemd.show_status=auto"  # Show status only when needed
      "mitigations=off" # Disable CPU vulnerability mitigations for speed (handheld use)
      "nowatchdog"      # Disable hardware watchdog for faster boot
      "modprobe.blacklist=iTCO_wdt,iTCO_vendor_support"  # Disable watchdog modules
    ];

    # Plymouth optimization for GPD display - Enhanced
    plymouth = {
      enable = true;
      theme = "breeze";  # Lightweight theme optimized for GPD
      themePackages = [ pkgs.breeze-plymouth ];
    };

    # Faster initrd for handheld devices - Enhanced
    initrd = {
      verbose = false;  # Reduce initrd output
      systemd.enable = true;  # Use systemd in initrd for parallel initialization

      # Optimize available commands for speed
      availableKernelModules = [
        "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"
        # Essential for GPD Pocket 3
        "i915"  # Intel graphics
        "snd_hda_intel"  # Audio
        "iwlwifi"  # WiFi
      ];

      # Preload essential kernel modules for GPD
      kernelModules = [
        "i915"          # Intel graphics early load
        "hid-generic"   # Input devices
        "usbhid"        # USB input
        "rtc-cmos"      # Real-time clock
      ];
    };

    # Optimize kernel modules loading
    kernelModules = [
      "kvm-intel"     # Virtualization support
      "iwlwifi"       # WiFi driver
      "btusb"         # Bluetooth support
    ];

    # Optimize module loading order for GPD hardware
    extraModulePackages = [ ];

    # Enhanced kernel parameters for performance
    kernel.sysctl = {
      "kernel.printk" = "3 3 3 3";  # Reduce kernel message verbosity
      "vm.dirty_writeback_centisecs" = 6000;  # Optimize disk writes for SSD
      "vm.laptop_mode" = 1;  # Enable laptop mode for better battery/performance balance
    };
  };

  # Optimize systemd for handheld device characteristics - Enhanced
  systemd = {
    # Reduce default timeouts for faster failure recovery
    extraConfig = ''
      DefaultTimeoutStartSec=15s
      DefaultTimeoutStopSec=8s
      DefaultRestartSec=2s
      DefaultLimitNOFILE=65536
    '';

    # Optimize user session startup
    user.extraConfig = ''
      DefaultTimeoutStartSec=15s
      DefaultTimeoutStopSec=8s
    '';

    # Sleep optimization for GPD Pocket 3
    sleep.extraConfig = ''
      HibernateDelaySec=30min
      SuspendState=mem
    '';
  };

  # Power-aware boot optimization - Enhanced
  powerManagement = {
    enable = true;
    # Resume quickly from suspend for handheld use patterns
    resumeCommands = ''
      sys="hyprland systemd coreutils"
      nix-shell -p $sys --run '
        echo "$(date): 🔋 GPD Resume Optimization Starting... (◕‿◕)"

        # Immediately restore display orientation for GPD
        hyprctl keyword monitor "DSI-1,1200x1920@60,0x0,1.5,transform,3" 2>/dev/null || true

        # Quick hardware re-initialization
        systemctl --user restart iio-sensor-proxy 2>/dev/null || true

        # Restore rotation service
        systemctl --user restart gpd-auto-rotate 2>/dev/null || true

        echo "$(date): ✅ Resume optimization complete ✨"
      '
    '';

    # Optimize suspend commands
    powerDownCommands = ''
      sys="coreutils"
      nix-shell -p $sys --run '
        echo "$(date): 💤 GPD Suspend Preparation... (◕‿◕)"

        # Save current rotation state
        cp /tmp/gpd-rotation-state /tmp/gpd-rotation-state.suspend 2>/dev/null || true

        echo "$(date): ✅ Suspend preparation complete ✨"
      '
    '';
  };

  # GPD-specific hardware readiness optimization - Enhanced
  services = {
    # Accelerometer service optimization
    hardware.sensor.iio = {
      enable = true;
    };

    # Optimize udev rules for faster GPD hardware detection
    udev.extraRules = ''
      # GPD Pocket 3 fast hardware detection with kaomoji logging
      SUBSYSTEM=="iio", KERNEL=="iio:device*", ATTRS{name}=="mxc4005", TAG+="systemd", ENV{SYSTEMD_WANTS}+="iio-sensor-proxy.service"
      SUBSYSTEM=="input", ATTRS{name}=="GXTP7380:00 27C6:0113", TAG+="systemd", RUN+="${pkgs.coreutils}/bin/logger 'GPD touchscreen detected ✨'"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="0113", TAG+="systemd", RUN+="${pkgs.coreutils}/bin/logger 'GPD input device ready 🎯'"

      # Optimize USB device detection
      SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="0113", TAG+="systemd"

      # Fast SSD detection for GPD storage
      SUBSYSTEM=="block", KERNEL=="nvme*", TAG+="systemd", ENV{SYSTEMD_WANTS}+="systemd-fsck@dev-%k.service"
    '';

    # Optimize journald for handheld device
    journald.extraConfig = ''
      SystemMaxUse=512M
      RuntimeMaxUse=64M
      MaxRetentionSec=7day
      MaxFileSec=1day
      ForwardToSyslog=no
    '';

    # Optimize logind for GPD Pocket 3
    logind.extraConfig = ''
      HandlePowerKey=suspend
      HandleLidSwitch=ignore
      HandleLidSwitchExternalPower=ignore
      IdleAction=suspend
      IdleActionSec=15min
    '';
  };

  # Environment optimizations for boot speed
  environment = {
    variables = {
      # Optimize shell startup
      LESSHISTFILE = "-";  # Disable less history file
      GROFF_NO_SGR = "1";  # Disable SGR sequences for faster man pages

      # GPD-specific optimizations
      GPD_BOOT_OPTIMIZED = "1";
      GPD_HANDHELD_MODE = "1";
    };

    # Essential packages only for faster boot
    systemPackages = with pkgs; [
      # Keep minimal for boot speed
      coreutils
      util-linux
      systemd
    ];

    # Optimize session variables
    sessionVariables = {
      # Reduce history sizes for faster shell startup
      HISTSIZE = "1000";
      SAVEHIST = "1000";

      # Optimize for GPD display
      GDK_SCALE = "1.5";
      GDK_DPI_SCALE = "1.0";
    };
  };

  # Network optimization for faster connectivity
  networking = {
    dhcpcd.wait = "background";  # Don't wait for DHCP to complete boot
    dhcpcd.extraConfig = ''
      # Fast DHCP for handheld devices
      timeout 30
      reboot 10
    '';
  };

  # File system optimizations
  fileSystems = {
    "/".options = [ "noatime" "compress=zstd" ];  # Optimize root filesystem
    "/home".options = [ "noatime" "compress=zstd" ];  # Optimize home filesystem
  };

  # Optimize font cache for GPD display
  fonts.fontconfig.cache32Bit = false;  # Disable 32-bit font cache for speed

  # Documentation optimization - reduce build time
  documentation = {
    enable = true;
    nixos.enable = false;  # Disable NixOS manual for faster builds
    man.enable = true;     # Keep man pages
    info.enable = false;   # Disable info pages for speed
  };

  # Nix optimization for handheld device
  nix.settings = {
    auto-optimise-store = true;
    min-free = 1024 * 1024 * 1024; # 1GB minimum free space
    max-free = 3 * 1024 * 1024 * 1024; # 3GB maximum free space
  };

  # Create GPD boot performance monitoring service
  systemd.user.services.gpd-boot-monitor = {
    enable = true;
    description = "GPD Boot Performance Monitor - Reboot Safe ✨";
    after = [ "graphical-session.target" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "gpd-boot-monitor" ''
        sys="coreutils systemd procps"
        nix-shell -p $sys --run '
          echo "$(date): 📊 GPD Boot Monitor Starting... (◕‿◕)"

          # Calculate boot time
          boot_time=$(systemd-analyze | head -n1 | grep -o "[0-9]*\.[0-9]*s" | head -n1 || echo "unknown")

          # Log boot performance with kaomoji
          echo "$(date): ⚡ GPD Boot completed in: $boot_time ✨" >> /tmp/gpd-boot-performance.log

          # Check critical services
          services_ready=0
          systemctl --user is-active waybar >/dev/null 2>&1 && services_ready=$((services_ready + 1))
          systemctl --user is-active gpd-auto-rotate >/dev/null 2>&1 && services_ready=$((services_ready + 1))

          echo "$(date): 🎯 Critical services ready: $services_ready/2" >> /tmp/gpd-boot-performance.log

          echo "$(date): ✅ Boot monitoring complete ＼(^o^)／"
        '
      '';
      Restart = "no";
      MemoryMax = "64M";
      CPUQuota = "15%";
      Environment = [
        "TERM=xterm-256color"
      ];
    };
  };
}