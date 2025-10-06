# Dynamic Hardware Configuration Wrapper for grOSs
#
# This wrapper enables the same grOSs flake to work across different systems:
# - On actual hardware: Uses /etc/nixos/hardware-configuration.nix (with --impure)
# - In CI/CD or new systems: Uses fallback configuration
#
# Usage: sudo nixos-rebuild switch --flake .#grOSs --impure

{ ... }:

{
  imports =
    if builtins.pathExists /etc/nixos/hardware-configuration.nix
    then [ /etc/nixos/hardware-configuration.nix ]
    else [ ./hardware-configuration-fallback.nix ];
}
