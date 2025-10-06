# Dynamic Hardware Configuration Wrapper for NaN
#
# This wrapper enables the same NaN flake to work across different systems:
# - On actual hardware: Uses /etc/nixos/hardware-configuration.nix (with --impure)
# - In CI/CD or new systems: Uses fallback configuration
#
# Usage: sudo nixos-rebuild switch --flake .#NaN --impure

{ ... }:

{
  imports =
    if builtins.pathExists /etc/nixos/hardware-configuration.nix
    then [ /etc/nixos/hardware-configuration.nix ]
    else [ ./hardware-configuration-fallback.nix ];
}
