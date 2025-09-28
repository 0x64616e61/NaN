{ pkgs, ... }:

{
  imports = [
    ./task-master.nix
    ./claude-code.nix
    ./applications
    ./audio
    ./desktop
    ./hyprland
    ./waybar
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
    
    applications.btop = {
      enable = true;  # Enable btop++ with persistent configuration
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
      enable = false;  # Disabled in favor of autoRotateService
      monitor = "DSI-1";  # GPD Pocket 3 DSI display
      scale = 1.5;  # Maintain 1.5x scale during rotation
    };
    
    desktop.autoRotateService = {
      enable = true;  # Enable dual-monitor auto-rotation service
    };
    
    desktop.libinputGestures = {
      enable = true;  # Enable touchscreen gestures for terminal scrolling
    };
    
    desktop.theme = {
      catppuccinMochaTeal = true;  # Permanent Catppuccin Mocha theme with teal accent
    };
    
    # Gesture support disabled - removed from configuration
    
    # Pure Nix modules (replacing HyDE)
    desktop.dmenuLauncher = {
      enable = false;  # Now handled by pure Nix Hyprland module
    };
    
    # HyDE-specific modules disabled (migrated to pure Nix)
    # desktop.workflowsGhostty.enable = false;
    # desktop.hydeGhostty.enable = false;
    # desktop.hyprlandGhostty.enable = false;

    # Monitor configuration now handled at system level in modules/system/monitor-config.nix
  };

  # Auto-start applications are now handled by pure Nix Hyprland module

  # Additional packages
  home.packages = with pkgs; [
    signal-cli
    android-tools  # includes adb and fastboot
    zip
    busybox
    patchelf
    androidenv.androidPkgs.ndk-bundle  # Android NDK
    gcc
    # Application launchers and window managers
    dmenu-wayland
    waybar
    dunst
    # Applications used in keybinds
    ghostty
    kdePackages.dolphin
    firefox
    pavucontrol
    # System utilities used in modules
    nodejs
    systemd
    coreutils
    libinput-gestures
  ];

  # Hydenix home-manager options
  hydenix.hm.enable = false;  # Disabled - migrated to pure Nix

  # Pure Nix modules enabled
  custom.hm.waybar.enable = true;
  custom.hm.hyprland.enable = true;
  
  # Disable hydenix waybar in favor of our pure Nix implementation
  hydenix.hm.waybar.enable = false;

  # Task-master configuration
  hydenix.hm.task-master = {
    enable = true;
    globalInstall = true;
    initializeProject = false;
  };

  # Claude-code configuration
  hydenix.hm.claude-code = {
    enable = true;
    shellAliases = true;  # Only option that still exists
  };

  # Git configuration using Hydenix module
  hydenix.hm.git = {
    enable = true;
    name = "a";
    email = "mini@nix";
  };
}