{ config, pkgs, ... }:

{
  imports = [
    ./applications
    ./audio
    ./desktop
    ./dwl
  ];

  # Enable custom modules
  custom.hm = {
    # DWL window manager
    dwl.enable = true;

    # Applications
    applications.musicPlayers.tidal = {
      enable = true;
      suspendInhibit = true;
    };

    applications.firefox = {
      enable = true;
      enableCascade = true;
    };

    applications.mpv = {
      enable = true;
      youtubeQuality = "1080";
      hwdec = "auto";
    };

    applications.ghostty = {
      enable = true;
    };

    applications.btop = {
      enable = true;
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
    desktop.autoRotateService = {
      enable = true;
    };

    desktop.touchscreen = {
      enable = true;
      rotation = 270;
    };

    gestures = {
      enable = true;
    };

    desktop.theme = {
      catppuccinMochaTeal = true;
    };

    # Wayland animations
    animations = {
      enable = true;
      notifications = {
        enable = true;
        fadeTime = 200;
      };
      compositor = {
        fadeWindows = true;
        fadeDuration = 150;
      };
    };
  };

  # Additional packages
  home.packages = with pkgs; [
    signal-cli
    android-tools
    zip
    busybox
    patchelf
    androidenv.androidPkgs.ndk-bundle
    gcc
    dmenu-wayland
    dmenu
    bemenu
    dunst
    swaybg
    ghostty
    yazi
    firefox
    pavucontrol
    nodejs
    systemd
    coreutils
    oh-my-posh
  ];


  # Git configuration
  programs.git = {
    enable = true;
    userName = "a";
    userEmail = "mini@nix";
  };

  # Home Manager state version
  home.stateVersion = "25.05";
}
