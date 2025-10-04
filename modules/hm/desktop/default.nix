{ ... }:
{
  imports = [
    # Core desktop modules
    ./hypridle.nix
    ./auto-rotate-service.nix
    ./theme.nix

    # Pure Nix modules
    ./waybar-pure-nix.nix  # Pure Nix waybar with fuzzel
    ../hyprland            # Pure Nix Hyprland configuration

    # Input and gesture modules
    ./hyprgrass-config.nix
    ./gestures.nix
  ];
}