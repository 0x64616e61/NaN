{ ... }:
{
  imports = [
    ./auto-rotate.nix
    ./monitoring.nix
    ./acpi-fixes.nix
    ./thermal-management.nix
  ];
}