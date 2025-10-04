{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.mpd;
in
{
  options.custom.system.mpd = {
    enable = mkEnableOption "MPD (Music Player Daemon) with user configuration";

    user = mkOption {
      type = types.str;
      default = "a";
      description = "User to run MPD as";
    };

    musicDirectory = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Directory containing music files (defaults to ~/Music)";
    };

    enableWeb = mkOption {
      type = types.bool;
      default = false;
      description = "Enable web interface on port 8080";
    };
  };

  config = mkIf cfg.enable (let
    userHome = config.users.users.${cfg.user}.home;
  in {
    # Enable MPD service
    services.mpd = {
      enable = true;
      musicDirectory = if cfg.musicDirectory != null then cfg.musicDirectory else "${userHome}/Music";
      user = cfg.user;
      group = "users";
      
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }
        
        # Enable HTTP streaming (optional)
        ${optionalString cfg.enableWeb ''
          audio_output {
            type "httpd"
            name "HTTP Stream"
            encoder "lame"
            port "8080"
            bitrate "320"
            format "44100:16:2"
          }
        ''}
        
        # Database settings
        db_file "~/.config/mpd/database"
        log_file "~/.config/mpd/log"
        playlist_directory "~/.config/mpd/playlists"
        pid_file "~/.config/mpd/pid"
        state_file "~/.config/mpd/state"
        sticker_file "~/.config/mpd/sticker.sql"
        
        # Network binding
        bind_to_address "localhost"
        port "6600"
        
        # Permissions
        default_permissions "read,add,control,admin"
      '';
      
      # Start after graphical session
      startWhenNeeded = false;  # Start automatically
    };
    
    # Create MPD directories
    systemd.tmpfiles.rules = [
      "d ${userHome}/.config/mpd 0755 ${cfg.user} users -"
      "d ${userHome}/.config/mpd/playlists 0755 ${cfg.user} users -"
    ];
    
    # Install MPD clients
    environment.systemPackages = with pkgs; [
      mpc  # Command-line client
      ncmpcpp  # Terminal UI client
      cantata  # GUI client
    ];
    
    # Open firewall for MPD if needed
    networking.firewall = mkIf cfg.enableWeb {
      allowedTCPPorts = [ 8080 ];
    };
  });
}
