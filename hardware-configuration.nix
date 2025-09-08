# PLACEHOLDER HARDWARE CONFIGURATION
# This file is a placeholder and will be automatically replaced
# with your system's hardware configuration when using nixos-rebuild --impure
# 
# If you're seeing an error, make sure to:
# 1. Run nixos-rebuild with the --impure flag
# 2. Or manually copy your hardware configuration here:
#    sudo cp /etc/nixos/hardware-configuration.nix /nix-modules/hardware-configuration.nix

{ config, lib, pkgs, modulesPath, ... }:

{
  # This is a placeholder configuration
  # It will be overridden by /etc/nixos/hardware-configuration.nix when available
  imports = [ ];
  
  # Minimal boot configuration to prevent errors
  boot.loader.grub.enable = lib.mkDefault false;
  
  # Warning message if this placeholder is actually being used
  warnings = [ "Using placeholder hardware-configuration.nix - system may not boot correctly!" ];
}
