# Hardware configuration wrapper
# This module handles hardware configuration for both local and flake builds
{ config, lib, pkgs, ... }:

let
  # Check if we have access to /etc/nixos (impure mode)
  hasSystemConfig = builtins.pathExists /etc/nixos;
  
  # Import the appropriate configuration
  hardwareImport = 
    if hasSystemConfig && builtins.pathExists /etc/nixos/hardware-configuration.nix
    then /etc/nixos/hardware-configuration.nix
    else ./hardware-configuration.nix;
in
{
  imports = [ hardwareImport ];
}
