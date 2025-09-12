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

    # Add udev rules for Vial keyboard access
    services.udev.extraRules = ''
      # Universal Vial rule - works with all Vial-enabled keyboards
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      
      # Generalized rule for VIA/Vial keyboards without specific serial
      # This is more permissive but ensures compatibility
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      
      # Additional rule for keyboards that might not properly identify
      # Covers most custom mechanical keyboards
      SUBSYSTEM=="usb", ATTRS{idVendor}=="feed", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", MODE="0660", GROUP="users", TAG+="uaccess"
      
      # QMK DFU bootloader rules (for flashing)
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff4", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffb", MODE="0660", GROUP="users", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff0", MODE="0660", GROUP="users", TAG+="uaccess"
    '';

    # Note: Ensure your user is in the 'users' group in configuration.nix
    # for proper Vial keyboard access
  };
}