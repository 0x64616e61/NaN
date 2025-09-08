{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.applications.musicPlayers;
in
{
  options.custom.hm.applications.musicPlayers = {
    tidal = {
      enable = mkEnableOption "Tidal HiFi music streaming";
      
      suspendInhibit = mkOption {
        type = types.bool;
        default = true;
        description = "Prevent system suspend while playing music";
      };
      
      package = mkOption {
        type = types.package;
        default = pkgs.tidal-hifi;
        description = "Tidal HiFi package to use";
      };
    };
  };

  config = mkIf cfg.tidal.enable {
    home.packages = [
      (if cfg.tidal.suspendInhibit then
        (pkgs.writeShellScriptBin "tidal-hifi" ''
          exec ${pkgs.systemd}/bin/systemd-inhibit \
            --what=sleep:idle \
            --who="Tidal HiFi" \
            --why="Music playback in progress" \
            ${cfg.tidal.package}/bin/tidal-hifi "$@"
        '')
      else
        cfg.tidal.package)
    ];
    
    # Create desktop entry for application menu
    xdg.desktopEntries."tidal-hifi" = {
      name = "TIDAL";
      genericName = "Music Streaming";
      comment = "Listen to music on TIDAL";
      exec = "tidal-hifi %U";
      icon = "tidal-hifi";
      terminal = false;
      type = "Application";
      categories = [ "Audio" "Music" "Player" "AudioVideo" ];
      mimeType = [ "x-scheme-handler/tidal" ];
      startupNotify = true;
    };
  };
}