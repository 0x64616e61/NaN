{ ... }:
{
  imports = [
    ./auto-rotate.nix
    ./focal-spi
    ./monitoring.nix
    ./acpi-fixes.nix
    # ./thermal-management.nix  # Temporarily disabled due to integer coercion issue
  ];
}