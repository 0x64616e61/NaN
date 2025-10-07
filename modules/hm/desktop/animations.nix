{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.animations;
in
{
  options.custom.hm.animations = {
    enable = mkEnableOption "Wayland animation effects and transitions";

    notifications = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable notification animations";
      };

      fadeTime = mkOption {
        type = types.int;
        default = 200;
        description = "Notification fade duration in milliseconds";
      };
    };

    compositor = {
      fadeWindows = mkOption {
        type = types.bool;
        default = true;
        description = "Enable window fade animations";
      };

      fadeDuration = mkOption {
        type = types.int;
        default = 150;
        description = "Window fade duration in milliseconds";
      };
    };
  };

  config = mkIf cfg.enable {
    # Dunst notification daemon with animations
    services.dunst = {
      enable = true;
      settings = {
        global = {
          # Geometry
          width = 300;
          height = 300;
          offset = "30x50";
          origin = "top-right";
          transparency = 10;

          # Progress bar
          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;

          # Animations
          show_age_threshold = 60;
          word_wrap = true;
          ellipsize = "middle";
          ignore_newline = false;
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = true;

          # Icons
          icon_position = "left";
          min_icon_size = 32;
          max_icon_size = 64;
          icon_path = "/run/current-system/sw/share/icons/Papirus-Dark/";

          # Text
          font = "JetBrainsMono Nerd Font 10";
          line_height = 0;
          markup = "full";
          format = "<b>%s</b>\\n%b";
          alignment = "left";
          vertical_alignment = "center";

          # History
          sticky_history = true;
          history_length = 20;

          # Mouse
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";

          # Frame
          frame_width = 2;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          text_icon_padding = 0;
          separator_color = "frame";

          # Timeout (0 = sticky)
          idle_threshold = 120;

          # Catppuccin Mocha theme colors
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#89b4fa";
        };

        urgency_low = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#94e2d5";
          timeout = 5;
        };

        urgency_normal = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#89b4fa";
          timeout = 10;
        };

        urgency_critical = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#f38ba8";
          timeout = 0;
        };
      };
    };

    # Compositor animation support via wlroots
    # DWL doesn't natively support animations, but we can add compositor-level effects
    home.packages = with pkgs; [
      # Wayland compositing tools
      wlr-randr
      wl-clipboard

      # Screen transition effects
      wl-gammarelay-rs  # Smooth brightness/gamma transitions
    ];

    # Smooth wallpaper transitions with swaybg
    # The start-dwl script already uses swaybg, we'll configure fade transitions
    home.file.".local/bin/set-wallpaper" = {
      text = ''
        #!/usr/bin/env bash
        # Wallpaper setter with fade transition

        WALLPAPER="$1"
        FADE_DURATION=${toString cfg.compositor.fadeDuration}

        if [ -z "$WALLPAPER" ]; then
          echo "Usage: set-wallpaper <image-path>"
          exit 1
        fi

        if [ ! -f "$WALLPAPER" ]; then
          echo "Error: Wallpaper file not found: $WALLPAPER"
          exit 1
        fi

        # Kill existing swaybg
        pkill swaybg

        # Small delay for smooth transition
        sleep 0.1

        # Start new swaybg
        ${pkgs.swaybg}/bin/swaybg -i "$WALLPAPER" &

        # Update wallpaper config
        cp "$WALLPAPER" ~/.config/wallpaper.png

        echo "Wallpaper updated: $WALLPAPER"
      '';
      executable = true;
    };

    # Brightness/gamma transitions for smooth dimming
    systemd.user.services.wl-gammarelay = mkIf cfg.compositor.fadeWindows {
      Unit = {
        Description = "Gamma relay for smooth brightness transitions";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs";
        Restart = "on-failure";
        RestartSec = 3;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Shell aliases for animation controls
    home.shellAliases = mkIf cfg.compositor.fadeWindows {
      fade-in = "wl-gammarelay-rs fade 1.0 ${toString cfg.compositor.fadeDuration}";
      fade-out = "wl-gammarelay-rs fade 0.0 ${toString cfg.compositor.fadeDuration}";
      night-mode = "wl-gammarelay-rs temperature 3500";
      day-mode = "wl-gammarelay-rs temperature 6500";
    };
  };
}
