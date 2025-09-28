{ ... }:
{
  imports = [
    ./hypridle.nix
    ./auto-rotate.nix
    ./auto-rotate-service.nix
    ./theme.nix
    ./waybar-pure-nix.nix  # Pure Nix waybar configuration
    # ./waybar-fix.nix  # Disabled - replaced with waybar-pure-nix.nix
    ./waybar-rotation-lock.nix
    ./waybar-rotation-patch.nix
    ./libinput-gestures.nix
    ./hyprgrass-config.nix
    ./gestures.nix
    # ./fusuma.nix  # Disabled due to Ruby gem installation issues in Nix
    ./workflows-ghostty.nix
    ./hyde-ghostty.nix
    ./hyprland-ghostty.nix
  ];
}