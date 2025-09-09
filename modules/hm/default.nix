{ pkgs, ... }:

{
  imports = [
    ./task-master.nix
    ./claude-code.nix
    ./applications
    ./audio
    ./desktop
  ];

  # Enable custom modules
  custom.hm = {
    # Applications
    applications.musicPlayers.tidal = {
      enable = true;
      suspendInhibit = true;  # Prevent suspend while playing music
    };
    
    applications.firefox = {
      enable = true;
      enableCascade = true;  # Enable Cascade theme
    };
    
    applications.mpv = {
      enable = true;
      youtubeQuality = "1080";  # Default to 1080p for GPD Pocket 3
      hwdec = "auto";  # Auto-detect hardware decoding
    };
    
    applications.kitty = {
      enable = false;  # Disabled - using Ghostty as main terminal
    };
    
    applications.ghostty = {
      enable = true;  # Enable Ghostty terminal as main shell
    };
    
    # Audio processing
    audio.easyeffects = {
      enable = true;
      preset = "Meze_109_Pro";
    };
    
    # Desktop environment
    desktop.hypridle = {
      override = true;
      screenTimeout = 60;     # Dim screen after 1 minute
      lockTimeout = 120;      # Lock after 2 minutes
      suspendTimeout = 900;   # Suspend after 15 minutes
      configFile = "/home/dm/hypridle-nodpms.conf";  # Custom config without DPMS for GPD Pocket 3
    };
    
    desktop.autoRotate = {
      enable = true;
      monitor = "DSI-1";  # GPD Pocket 3 DSI display
      scale = 1.5;  # Maintain 1.5x scale during rotation
    };
    
    desktop.libinputGestures = {
      enable = true;  # Enable touchscreen gestures for terminal scrolling
    };
    
    desktop.theme = {
      catppuccinMochaTeal = true;  # Permanent Catppuccin Mocha theme with teal accent
    };
    
    # Gesture support disabled - removed from configuration
    
    desktop.waybarFix = {
      enable = true;  # Fix waybar startup by uncommenting $start.BAR
    };
    
    
    desktop.workflowsGhostty = {
      enable = true;  # Persistent ghostty terminal configuration
    };
    
    desktop.hydeGhostty = {
      enable = true;  # Configure HyDE to use ghostty
    };
    
    # Monitor configuration now handled at system level in modules/system/monitor-config.nix
  };

  # Auto-start applications
  wayland.windowManager.hyprland.settings.exec-once = [
    # waybar is managed by HyDE's waybar.py script - don't start it directly
    "keepassxc ~/Documents/Passwords.kdbx"  # For secret service
    # Auto-rotate is now handled by systemd service
  ];
  
  # Ensure monitor is set to landscape in Hyprland config directly
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DSI-1, 1200x1920@60, 0x0, 1.5, transform, 3"
    ];
    
    # Also run on startup to ensure landscape is applied
    exec = [
      "hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.5,transform,3"
    ];
  };

  # Additional packages
  home.packages = with pkgs; [
    signal-cli
  ];

  # Hydenix home-manager options
  hydenix.hm.enable = true;

  # Task-master configuration
  hydenix.hm.task-master = {
    enable = true;
    globalInstall = true;
    initializeProject = false;
  };

  # Claude-code configuration
  hydenix.hm.claude-code = {
    enable = true;
    globalInstall = true;
    autoUpdate = true;
    shellAliases = true;
  };
}