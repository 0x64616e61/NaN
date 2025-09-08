{ config, pkgs, lib, ... }:

let
  cfg = config.custom.hm.applications.kitty;
in
{
  options.custom.hm.applications.kitty = {
    enable = lib.mkEnableOption "Kitty terminal emulator with touchscreen support";
  };

  config = lib.mkIf cfg.enable {
    # Extend existing Kitty configuration with touchscreen support
    programs.kitty.settings = lib.mkMerge [
      {
        # Enable touch scrolling (requires Wayland)
        touch_scroll_multiplier = "5.0";
        
        # Mouse and input settings for better touch support
        mouse_hide_wait = "3.0";
        focus_follows_mouse = "yes";
        
        # Scrollback settings
        scrollback_lines = "10000";
        scrollback_pager = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";
        scrollback_pager_history_size = "0";
        wheel_scroll_multiplier = "5.0";
        wheel_scroll_min_lines = "1";
        
        # Touch gesture support
        strip_trailing_spaces = "smart";
        
        # Performance settings for smooth scrolling
        repaint_delay = "10";
        input_delay = "3";
        sync_to_monitor = "yes";
        
        # Wayland-specific settings for better touch support
        wayland_enable_ime = "yes";
        linux_display_server = "wayland";
      }
    ];
    
    # Add key bindings for better touch interaction
    programs.kitty.keybindings = lib.mkMerge [
      {
        # Scroll with page up/down
        "shift+page_up" = "scroll_page_up";
        "shift+page_down" = "scroll_page_down";
        "ctrl+shift+k" = "scroll_line_up";
        "ctrl+shift+j" = "scroll_line_down";
        "ctrl+shift+home" = "scroll_home";
        "ctrl+shift+end" = "scroll_end";
        
        # Additional scroll bindings for gesture integration
        "alt+up" = "scroll_line_up";
        "alt+down" = "scroll_line_down";
        "alt+page_up" = "scroll_page_up";
        "alt+page_down" = "scroll_page_down";
      }
    ];
    
    # Add extra config for additional touch configurations
    programs.kitty.extraConfig = ''
      # Enable kinetic scrolling (smooth momentum scrolling)
      # This helps with touch scrolling experience
      touch_scroll_multiplier 5.0
      
      # Map additional touch gestures to scroll actions
      map ctrl+shift+up scroll_line_up
      map ctrl+shift+down scroll_line_down
    '';
  };
}