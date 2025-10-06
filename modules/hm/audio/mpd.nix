{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.audio.mpd;
in
{
  options.custom.hm.audio.mpd = {
    enable = mkEnableOption "Music Player Daemon with local library";
    
    musicDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Music";
      description = "Directory containing music library";
    };
  };

  config = mkIf cfg.enable {
    services.mpd = {
      enable = true;
      musicDirectory = cfg.musicDirectory;
      
      extraConfig = ''
        # Audio output
        audio_output {
          type "pipewire"
          name "PipeWire Audio"
        }
        
        # Database
        database {
          plugin "simple"
          path "${config.xdg.dataHome}/mpd/database"
          cache_directory "${config.xdg.cacheHome}/mpd"
        }

        # Behavior
        auto_update "yes"
        auto_update_depth "10"
        
        # Network
        bind_to_address "127.0.0.1"
        port "6600"
        
        # State files
        state_file "${config.xdg.dataHome}/mpd/state"
        sticker_file "${config.xdg.dataHome}/mpd/sticker.sql"
        playlist_directory "${config.xdg.dataHome}/mpd/playlists"
        
        # Logging
        log_file "syslog"
        
        # Performance
        connection_timeout "60"
        max_connections "10"
        max_playlist_length "16384"
        max_command_list_size "2048"
        max_output_buffer_size "8192"
        
        # Character encoding
        filesystem_charset "UTF-8"
      '';
    };

    # MPC command-line client
    home.packages = with pkgs; [
      mpc-cli
      cantata
    ];

    # Create required directories
    home.file.".local/share/mpd/.keep".text = "";
    home.file.".cache/mpd/.keep".text = "";
  };
}
