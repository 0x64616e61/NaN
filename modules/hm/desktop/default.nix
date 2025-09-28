{ ... }:
{
  imports = [
    ./hypridle.nix
    ./auto-rotate.nix
    ./auto-rotate-service.nix
    ./theme.nix
    ./waybar-pure-nix.nix  # OLED monochrome waybar configuration
    ./libinput-gestures.nix
    ./hyprgrass-config.nix
    ./gestures.nix
    # ./fusuma.nix  # Disabled due to Ruby gem installation issues in Nix
    ./workflows-ghostty.nix
    ./hyde-ghostty.nix
    ./hyprland-ghostty.nix
  ];
}