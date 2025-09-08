{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.hyprgrass;
in
{
  options.custom.system.hyprgrass = {
    enable = mkEnableOption "Hyprgrass touchscreen gesture plugin for Hyprland";
  };

  config = mkIf cfg.enable {
    # Install hyprgrass plugin from nixpkgs
    environment.systemPackages = [
      pkgs.hyprlandPlugins.hyprgrass
    ];
  };
}