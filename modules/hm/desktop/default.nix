{ ... }:
{
  imports = [
    # Core desktop modules
    ./hypridle.nix
    ./auto-rotate.nix
    ./auto-rotate-service.nix
    ./theme.nix
    
    # Pure Nix modules (replacing HyDE)
    ./dmenu-launcher.nix
    ../waybar         # Pure Nix waybar configuration
    ../hyprland       # Pure Nix Hyprland configuration
    
    # Input and gesture modules
    ./libinput-gestures.nix
    ./hyprgrass-config.nix
    ./gestures.nix
    
    # Disabled modules
    # ./fusuma.nix  # Disabled due to Ruby gem installation issues
    # ./waybar-pure-nix.nix  # Replaced by ../waybar
    # ./workflows-ghostty.nix  # HyDE-specific, removed
    # ./hyde-ghostty.nix  # HyDE-specific, removed
    # ./hyprland-ghostty.nix  # Replaced by ../hyprland
  ];
}