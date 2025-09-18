{ config, lib, pkgs, ... }:

{
  # System packages - CLI tools from your NixOS config
  environment.packages = with pkgs; [
    # Core essentials
    vim
    # neovim is configured in home.nix with programs.neovim

    # Version control and development
    # git is configured in home.nix with programs.git
    gh  # GitHub CLI
    openssh  # SSH client for git operations

    # System utilities from your config
    procps
    killall
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip

    # From your NixOS config
    # btop is configured in home.nix with programs.btop
    pandoc
    openvpn
    gptfdisk
    parted
    disko

    # Media tools (CLI only)
    # mpv is configured in home.nix with programs.mpv
    yt-dlp  # YouTube downloader
    youtube-tui  # Terminal YouTube interface

    # Common CLI utilities
    curl
    wget
    jq
    ripgrep
    fd
    # bat is configured in home.nix with programs.bat
    eza  # Modern ls replacement
    # zoxide is configured in home.nix with programs.zoxide
    # fzf is configured in home.nix with programs.fzf
    # tmux is configured in home.nix with programs.tmux

    # Archive tools
    p7zip

    # Process management
    htop

    # Network utilities
    nmap
    dig
    traceroute
    iproute2  # For ip command
    nettools  # For ifconfig

    # Security tools
    keepassxc  # CLI mode available

    # Audio tools (CLI components)
    ncmpcpp  # MPD client

    # System information
    neofetch

    # File sync
    rsync

    # JSON/YAML tools
    yq-go

    # Task management and AI tools (from your modules)
    nodejs  # For task-master and claude-code

    # Music server (from mpd.nix)
    mpd
    mpc-cli  # MPD command-line client

    # Audio support for Nix-on-Droid
    pulseaudio  # Audio daemon
    gst_all_1.gstreamer  # GStreamer core
    gst_all_1.gst-plugins-base  # Base plugins
    gst_all_1.gst-plugins-good  # Good plugins
    gst_all_1.gst-plugins-bad  # Additional plugins
    gst_all_1.gst-plugins-ugly  # Codec plugins

    # Additional tools from your configuration
    libimobiledevice  # iPhone USB support (CLI tools work)
    ifuse  # Mount iPhone filesystem (if supported on Android)
    zfstools  # ZFS tools (may have limited use on Android)

    # Python is provided in home.nix with packages
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    warn-dirty = false
  '';

  # Set your time zone (matching GPD Pocket 3 setup)
  time.timeZone = "America/Los_Angeles";

  # Set terminal
  terminal = {
    font = "${pkgs.nerdfonts}/share/fonts/truetype/NerdFonts/CaskaydiaCoveNerdFontMono-Regular.ttf";
    colors = {
      # Catppuccin Mocha theme (matching your desktop)
      foreground = "#CDD6F4";
      background = "#1E1E2E";

      # Normal colors
      color0 = "#45475A";  # black
      color1 = "#F38BA8";  # red
      color2 = "#A6E3A1";  # green
      color3 = "#F9E2AF";  # yellow
      color4 = "#89B4FA";  # blue
      color5 = "#F5C2E7";  # magenta
      color6 = "#94E2D5";  # cyan (teal accent)
      color7 = "#BAC2DE";  # white

      # Bright colors
      color8 = "#585B70";   # bright black
      color9 = "#F38BA8";   # bright red
      color10 = "#A6E3A1";  # bright green
      color11 = "#F9E2AF";  # bright yellow
      color12 = "#89B4FA";  # bright blue
      color13 = "#F5C2E7";  # bright magenta
      color14 = "#94E2D5";  # bright cyan
      color15 = "#A6ADC8";  # bright white
    };
  };

  # Set default shell to zsh
  user.shell = "${pkgs.zsh}/bin/zsh";

  # Configure home-manager
  home-manager = {
    config = ./home.nix;
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  };
}
