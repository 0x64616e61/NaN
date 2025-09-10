{ ... }:
{
  imports = [
    ./hypridle.nix
    ./auto-rotate.nix
    ./auto-rotate-service.nix
    ./theme.nix
    ./waybar-fix.nix
    ./waybar-rotation-lock.nix
    ./waybar-rotation-patch.nix
    ./libinput-gestures.nix
    ./workflows-ghostty.nix
    ./hyde-ghostty.nix
  ];
}