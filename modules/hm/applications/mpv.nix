{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.applications.mpv;
in
{
  options.custom.hm.applications.mpv = {
    enable = mkEnableOption "MPV media player with YouTube support";
    
    youtubeQuality = mkOption {
      type = types.str;
      default = "best";
      description = "Default YouTube video quality (best, 1080, 720, etc.)";
    };
    
    hwdec = mkOption {
      type = types.str;
      default = "auto";
      description = "Hardware decoding method (auto, vaapi, etc.)";
    };
  };

  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      
      config = {
        # Video output
        vo = "gpu";
        hwdec = cfg.hwdec;
        gpu-context = "wayland";
        
        # YouTube playback
        ytdl-format = "bestvideo[height<=?${if cfg.youtubeQuality == "best" then "9999" else cfg.youtubeQuality}]+bestaudio/best";
        ytdl-raw-options = "ignore-errors=,sub-lang=en,write-auto-sub=";
        
        # Performance
        cache = "yes";
        cache-secs = 300;
        cache-pause = true;
        cache-pause-initial = true;
        demuxer-max-bytes = "500M";
        demuxer-max-back-bytes = "250M";
        
        # UI
        osc = true;
        osd-bar = true;
        osd-font-size = 35;
        
        # Subtitles
        sub-auto = "fuzzy";
        sub-font-size = 40;
        
        # Audio
        volume = 100;
        volume-max = 150;
        audio-file-auto = "fuzzy";
        audio-pitch-correction = true;

        # Music mode settings
        term-osd-bar = true;
        msg-color = true;

        # Screenshots
        screenshot-directory = "~/Pictures/mpv";
        screenshot-format = "png";
        screenshot-template = "%F-%P";
      };
      
      bindings = {
        # YouTube specific
        "y" = "cycle-values ytdl-format \"bestvideo[height<=?720]+bestaudio/best\" \"bestvideo[height<=?1080]+bestaudio/best\" \"bestvideo+bestaudio/best\"";
        "Y" = "script-binding quality_menu/video_formats_toggle";
        
        # Playback speed
        "[" = "multiply speed 0.9";
        "]" = "multiply speed 1.1";
        "{" = "multiply speed 0.5";
        "}" = "multiply speed 2.0";
        "BACKSPACE" = "set speed 1.0";
        
        # Seeking
        "RIGHT" = "seek 5";
        "LEFT" = "seek -5";
        "UP" = "seek 60";
        "DOWN" = "seek -60";
        
        # Volume
        "WHEEL_UP" = "add volume 2";
        "WHEEL_DOWN" = "add volume -2";
        "m" = "cycle mute";
        
        # Screenshot
        "s" = "screenshot";
        "S" = "screenshot video";
        "Alt+s" = "screenshot each-frame";
      };
      
      scripts = with pkgs.mpvScripts; [
        sponsorblock
        quality-menu
        mpris
      ];
    };
    
    # Create mpv config directory for manual configs if needed
    home.file.".config/mpv/.keep".text = "";
    
    # Ensure screenshot directory exists
    home.file."Pictures/mpv/.keep".text = "";
  };
}