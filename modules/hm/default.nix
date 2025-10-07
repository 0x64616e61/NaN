{ config, pkgs, ... }:

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

    audio.mpd = {
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/Music";
    };
    
    # Desktop environment
    desktop.hypridle = {
      enable = true;
      screenTimeout = 60;     # Turn off screen after 1 minute
      suspendTimeout = 900;   # Suspend after 15 minutes
    };

    desktop.autoRotateService = {
      enable = true;  # Enable dual-monitor auto-rotation service
    };

    waybar = {
      enable = true;        # Enable full-featured waybar
    };

    desktop.theme = {
      catppuccinMochaTeal = true;  # Permanent Catppuccin Mocha theme with teal accent
    };

    desktop.hyprgrass = {
      enable = true;  # Enable 3-finger touchscreen gestures
      sensitivity = 4.0;  # Optimized for touchscreen
    };

    desktop.rebuildKeybind = {
      enable = true;  # Enable Windows+Insert for NixOS rebuild
    };
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
    dmenu
    bemenu
    eww  # Widget system for status bar
    socat  # For eww workspace scripts
    jq  # For eww JSON processing
    dunst
    swaybg  # Wallpaper daemon
    # Applications used in keybinds
    ghostty
    yazi  # Terminal file manager
    firefox
    pavucontrol
    moonlight-qt  # Game streaming client (NVIDIA GameStream/Sunshine)
    # System utilities used in modules
    nodejs
    systemd
    coreutils
    # libinput-gestures removed - redundant with native Hyprland gestures, requires touchpad not touchscreen
    # Shell prompt
    oh-my-posh
  ];

  # Pure Nix modules enabled
  custom.hm.hyprland.enable = true;

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