{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.input.vial;
in
{
  options.custom.system.input.vial = {
    enable = mkEnableOption "Vial keyboard configurator with proper udev rules";
  };

  config = mkIf cfg.enable {
    # Install Vial package
    environment.systemPackages = with pkgs; [
      vial
    ];

    # Add udev rules for Vial keyboard access (Official Vial rules with proper syntax)
    services.udev.extraRules = ''
      # Official Universal Vial rule from get.vial.today
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

      # Kyria-specific vendor IDs (Pro Micro controllers)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1b4f", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2341", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="239a", MODE="0660", GROUP="users", TAG+="uaccess"

      # Additional QMK/VIA/Vial vendor IDs
      SUBSYSTEM=="usb", ATTRS{idVendor}=="feed", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="16c0", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04d8", MODE="0660", GROUP="users", TAG+="uaccess"

      # Generalized rule for VIA/Vial keyboards without specific serial
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"

      # QMK DFU bootloader rules (for flashing firmware)
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff4", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffb", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff0", MODE="0660", GROUP="users", TAG+="uaccess"

      # Caterina bootloader (common in Pro Micro)
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9203", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9205", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0036", MODE="0660", GROUP="users", TAG+="uaccess"
    '';

    # Note: Ensure your user is in the 'users' group in configuration.nix
    # for proper Vial keyboard access
  };
}