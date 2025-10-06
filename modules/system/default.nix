{ pkgs, ... }:

{
  imports = [
    ./hardware
    ./security
    ./packages
    ./input
    ./network
    ./backup.nix
    ./wayland-screenshare.nix
    ./boot.nix
    ./plymouth.nix
    ./monitor-config.nix
    ./display-management.nix
    ./grub-theme.nix
    ./mpd.nix
    ./dwl-custom.nix
    ./update-alias.nix
    ./touchscreen-pen.nix
  ];

  # Enable custom modules with clean configuration
  custom.system = {
    # Monitor configuration for GPD Pocket 3
    monitor = {
      enable = true;
      name = "DSI-1";
      resolution = "1200x1920@60";
      position = "0x0";
      scale = 1.5;
      transform = 3;  # 270 degree rotation (landscape mode)
    };

    # Hardware features for GPD Pocket 3

    hardware.acpiFixes = {
      enable = true;
      useOverride = true;
    };

    hardware.thermal = {
      enable = true;
      enableThermald = true;
      normalGovernor = "schedutil";
      emergencyShutdownTemp = 95;
      criticalTemp = 90;
      throttleTemp = 80;
    };


    # Security
    security.fingerprint = {
      enable = true;
      enableSddm = true;
      enableSudo = true;
      enableSwaylock = true;
    };

    security.secrets = {
      enable = true;
      provider = "gnome-keyring";
    };

    security.hardening = {
      enable = true;
      restrictSSH = true;
      closeGamingPorts = false;
    };

    # Network Configuration
    network.iphoneUsbTethering = {
      enable = true;
      autoConnect = true;
      connectionPriority = 15;
    };

    # Display management
    displayManagement = {
      enable = true;
      tools = {
        wlrRandr = true;
        wdisplays = true;
        kanshi = true;
      };
    };

    # Package modules
    packages.email = {
      enable = true;
    };

    packages.displayRotation = {
      enable = true;
    };

    # Input configuration
    input.keyd = {
      enable = true;
    };

    input.vial = {
      enable = true;
    };

    # MPD (disabled - using home-manager MPD instead to avoid port conflict)
    mpd = {
      enable = false;
    };
  };

  # DWL and essential Wayland packages
  environment.systemPackages = with pkgs; [
    # dwl compositor and bar
    dwl

    # Status bar utilities
    pamixer
    brightnessctl
    lm_sensors
    bluez
    procps

    # Wayland essentials
    swaybg
    swayidle
    swaylock
    wlr-randr
    wl-clipboard

    # Terminal and launcher
    foot
    bemenu
    dmenu-wayland

    # Notifications
    dunst

    # Essential tools (from nix-modules)
    x2goclient
    pandoc
    texlive.combined.scheme-full
    krita
    youtube-tui
    openvpn
    gptfdisk
    parted
    gh
    chromium
    btop
    iotop
    sysstat
    lynis
    signal-desktop
    spotify
    libimobiledevice
    ifuse
    zfs

    # Media
    mpv
    yt-dlp
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    spotifyd
    moonlight-qt
  ];

}
