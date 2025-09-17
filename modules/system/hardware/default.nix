{ ... }:
{
  imports = [
    ./auto-rotate.nix
    ./focal-spi
    # ./monitoring.nix  # DISABLED: Permission conflicts causing crashes
  ];
}
