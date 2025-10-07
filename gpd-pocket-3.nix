# GPD Pocket 3 Complete NixOS Optimization
# Combines: dana boot reliability + nix-modules patterns + ArchWiki touchscreen fix
{ config, lib, pkgs, ... }:

{
  # Official nixos-hardware GPD Pocket 3 support
  imports = [ ];

  boot = {
    # Dana: systemd initrd for parallel boot
    initrd = {
      systemd.enable = true;
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "i915" ];  # Intel Iris Xe GPU - early load
    };
    
    kernelModules = [ "kvm-intel" ];
    
    # ArchWiki + dana: Display rotation + quiet boot
    kernelParams = [
      "fbcon=rotate:1"  # Console rotation for 90° counter-clockwise display
      "video=DSI-1:panel_orientation=right_side_up"  # Rotate Plymouth/Wayland/GDM
      "quiet"
      "splash"
      "loglevel=3"
      "boot.shell_on_fail"
    ];
    
    # Dana: Fast bootloader
  };

  # ArchWiki: Audio fix for 1195G7 model
  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=1
  '';

  # ArchWiki + dana: Touchscreen calibration for Wayland
  services.udev.extraRules = ''
    # GPD Pocket 3 touchscreen rotation calibration
    # Transforms touchscreen coordinates for 90° clockwise rotation
    ACTION=="add|change", KERNEL=="event[0-9]*", ATTRS{name}=="GXTP7380:00 27C6:0113", ENV{LIBINPUT_CALIBRATION_MATRIX}="0 1 0 -1 0 1"
  '';

  # Dana: IIO sensor support for accelerometer
  hardware.sensor.iio.enable = true;

  # Dana: Systemd manager defaults (all services hardened)
  systemd.settings.Manager = {
    DefaultPrivateTmp = "yes";
    DefaultNoNewPrivileges = "yes";
    DefaultCPUAccounting = "yes";
    DefaultMemoryAccounting = "yes";
  };

  # Optional: HiDPI scaling for small screen
}
