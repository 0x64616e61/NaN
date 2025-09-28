{ ... }:
{
  imports = [
    ./auto-rotate.nix
    ./focal-spi
    ./monitoring.nix
    # ./thermal-management.nix  # Temporarily disabled due to integer coercion issue
  ];
}