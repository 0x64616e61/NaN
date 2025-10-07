{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.rebuildKeybind;

  rebuildScript = pkgs.writeShellScriptBin "nixos-rebuild-service" ''
    #!/usr/bin/env bash
    cd /home/a/NaN
    sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .#NaN --impure
  '';
in
{
  options.custom.hm.desktop.rebuildKeybind = {
    enable = mkEnableOption "Enable Windows+Insert keybind for NixOS rebuild";
  };

  config = mkIf cfg.enable {
    # Systemd service for rebuild
    systemd.user.services.nixos-rebuild-trigger = {
      Unit = {
        Description = "NixOS Rebuild via keybind";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${rebuildScript}/bin/nixos-rebuild-service";
      };
    };

    # Add keybind to Hyprland
    wayland.windowManager.hyprland.settings.bind = [
      "$mainMod, Insert, exec, systemctl --user start nixos-rebuild-trigger.service"
    ];

    # Make script available
    home.packages = [ rebuildScript ];
  };
}
