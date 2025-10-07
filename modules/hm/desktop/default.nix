{ ... }:
{
  imports = [
    # Core desktop modules
    ./hypridle.nix
    ./auto-rotate-service.nix
    ./theme.nix

    # Pure Nix modules
    ../hyprland            # Pure Nix Hyprland configuration

    # Input and gesture modules
    ./hyprgrass-config.nix
    ./gestures.nix
  ];
}