{ config, lib, pkgs, ... }:

{
  # System packages - CLI tools from your NixOS config
  environment.packages = with pkgs; [
    # Core essentials
    vim
    neovim

    # Version control and development
    git
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
    btop  # Beautiful system monitor
    pandoc
    openvpn
    gptfdisk
    parted
    disko

    # Media tools (CLI only)
    mpv  # Can work in terminal with --vo=tct
    yt-dlp  # YouTube downloader
    youtube-tui  # Terminal YouTube interface

    # Common CLI utilities
    curl
    wget
    jq
    ripgrep
    fd
    bat
    eza  # Modern ls replacement
    zoxide  # Smart cd
    fzf  # Fuzzy finder
    tmux  # Terminal multiplexer

    # Archive tools
    p7zip

    # Process management
    htop

    # Network utilities
    nmap
    dig
    traceroute

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
    mpc  # MPD command-line client

    # Additional tools from your configuration
    libimobiledevice  # iPhone USB support (CLI tools work)
    ifuse  # Mount iPhone filesystem (if supported on Android)
    zfstools  # ZFS tools (may have limited use on Android)

    # Python for SuperClaude (if you want to add it later)
    (python3.withPackages (ps: with ps; [
      pip
      setuptools
      wheel
      requests
      click
      pyyaml
      rich
    ]))
  ];

  # Shell aliases from update-alias.nix (adapted for Nix-on-Droid)
  environment.shellAliases = {
    # Quick update command (adapted for Nix-on-Droid)
    "update!" = ''
      cd ~/nix-modules 2>/dev/null || cd ~ && \
      if [ -n "$(git status --porcelain 2>/dev/null)" ]; then \
        echo "[+] Committing changes..." && \
        git add -A && \
        git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')" && \
        echo "[>] Pushing to GitHub..." && \
        git push origin main 2>/dev/null || echo "[!] Push failed - check git credentials"; \
      fi && \
      echo "[*] Rebuilding Nix-on-Droid..." && \
      nix-on-droid switch --flake .
    '';

    # Work summary using available tools
    "worksummary" = ''
      cd ~/nix-modules 2>/dev/null || cd ~ && \
      echo "Creating work summary..." && \
      git log --since="12 hours ago" --oneline
    '';
  };

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
