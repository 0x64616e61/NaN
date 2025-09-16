{ config, lib, pkgs, ... }:

{
  # Optimized packages for mobile development environment
  environment.packages = with pkgs; [
    # === Core Development Tools ===
    git              # Version control
    neovim           # Text editor
    tmux             # Terminal multiplexer
    openssh          # SSH client

    # === Modern CLI Replacements ===
    ripgrep          # Fast grep (rg)
    fd               # Fast find
    bat              # Cat with syntax highlighting
    eza              # Modern ls replacement
    zoxide           # Smart cd
    starship         # Cross-platform prompt
    fzf              # Fuzzy finder

    # === Development Runtimes ===
    nodejs           # JavaScript runtime
    python3          # Python interpreter
    gcc              # C/C++ compiler

    # === Network & Connectivity ===
    curl             # HTTP client
    wget             # File downloader
    nmap             # Network scanner
    tailscale        # Secure networking

    # === File Sync & Management ===
    syncthing        # P2P file sync with GPD
    rclone           # Cloud storage sync

    # === System Monitoring ===
    btop             # Beautiful resource monitor
    neofetch         # System info display

    # === GitHub Integration ===
    gh               # GitHub CLI for mobile commits

    # === Additional Utilities ===
    jq               # JSON processor
    yq               # YAML processor
    tree             # Directory tree viewer
    ncdu             # Disk usage analyzer
    unzip            # Archive extraction
    zip              # Archive creation
  ];

  # Shell configuration
  user.shell = "${pkgs.zsh}/bin/zsh";

  # Zsh configuration - matching GPD setup
  programs.zsh = {
    enable = true;
    shellAliases = {
      # === Navigation (same as GPD) ===
      ls = "eza --icons";
      ll = "eza -la --icons";
      la = "eza -la --icons";
      tree = "eza --tree --icons";
      cd = "z";  # Use zoxide

      # === Git Aliases (matching GPD workflow) ===
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gb = "git branch";
      gco = "git checkout";
      gcm = "git commit -m";

      # === Nix-on-Droid Specific ===
      rebuild = "nix-on-droid switch --flake .#pixel9pro";
      update = "nix flake update";
      clean = "nix-collect-garbage -d";

      # === SSH to GPD (multiple connection methods) ===
      gpd = "ssh a@10.42.0.1";           # GPD hotspot
      gpd-usb = "ssh a@10.42.0.2";       # USB tethering (if configured)
      gpd-ts = "ssh a@mini";              # Via Tailscale
      mini = "ssh a@mini";                # Quick alias

      # === Quick Edits ===
      v = "nvim";
      vim = "nvim";
      conf = "nvim ~/nix-on-droid/configuration.nix";

      # === System Info ===
      sys = "neofetch";
      mon = "btop";

      # === File Operations ===
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -iv";
      mkdir = "mkdir -pv";
    };

    initExtra = ''
      # Starship prompt - same config as GPD
      eval "$(starship init zsh)"

      # Zoxide for smart navigation
      eval "$(zoxide init zsh --cmd z)"

      # FZF keybindings for history search
      source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
      source "${pkgs.fzf}/share/fzf/completion.zsh"

      # Set default editor
      export EDITOR=nvim
      export VISUAL=nvim

      # Path additions for local binaries
      export PATH="$HOME/.local/bin:$PATH"

      # Better history management
      HISTSIZE=10000
      SAVEHIST=10000
      setopt HIST_IGNORE_DUPS
      setopt SHARE_HISTORY

      # Enable vi mode
      bindkey -v

      # Useful functions
      mkcd() { mkdir -p "$1" && cd "$1"; }

      # Quick sync check
      sync-status() {
        echo "=== Syncthing Status ==="
        curl -s http://localhost:8384/rest/system/status | jq -r '.myID'
      }
    '';
  };

  # SSH client configuration - optimized for GPD access
  programs.ssh = {
    enable = true;
    extraConfig = ''
      # === GPD Pocket 3 Connection Options ===

      # Via GPD WiFi Hotspot
      Host gpd gpd-hotspot
        HostName 10.42.0.1
        User a
        Port 22
        # Quick reconnect on network changes
        ServerAliveInterval 60
        ServerAliveCountMax 3
        TCPKeepAlive yes

      # Via USB Tethering (when phone is USB-connected to GPD)
      Host gpd-usb
        HostName 10.42.0.2
        User a
        Port 22

      # Via Tailscale (most reliable)
      Host mini gpd-ts gpd-tailscale
        HostName mini
        User a
        Port 22
        # Tailscale is more stable, less aggressive keepalive
        ServerAliveInterval 120

      # === Global SSH Optimizations for Mobile ===
      Host *
        # Reuse connections for faster subsequent access
        ControlMaster auto
        ControlPath ~/.ssh/sockets-%r@%h-%p
        ControlPersist 600

        # Faster connection on mobile networks
        Compression yes

        # Handle network changes gracefully
        StrictHostKeyChecking accept-new

        # Speed up connection initialization
        GSSAPIAuthentication no
    '';
  };

  # Syncthing configuration for GPD-Phone sync
  services.syncthing = {
    enable = true;
    dataDir = "/data/data/com.termux.nix/files/home";
    # Configuration will be at ~/.config/syncthing
    # Folders to sync:
    # - ~/Documents - Shared documents
    # - ~/Projects - Development projects
    # - ~/Scripts - Utility scripts
    # - ~/Sync - General sync folder
  };

  # Starship prompt configuration (matching GPD theme)
  programs.starship = {
    enable = true;
    settings = {
      format = ''
        [┌─ ](bold green)$os$username$hostname$directory$git_branch$git_status
        [└─❯](bold green)
      '';

      os = {
        disabled = false;
        format = "[$symbol ]($style)";
        style = "bold blue";
        symbols = {
          Android = "🤖";
        };
      };

      username = {
        show_always = false;
        format = "[$user]($style) @ ";
        style_user = "bold cyan";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) in ";
        style = "bold purple";
      };

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "bold yellow";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        format = "on [$symbol$branch]($style) ";
        style = "bold green";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style)";
        style = "bold red";
      };
    };
  };

  # Nix settings
  nix = {
    # Enable flakes
    extraConfig = ''
      experimental-features = nix-command flakes
    '';

    # Substituters for faster downloads
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trustedPublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Terminal settings - Catppuccin Mocha (matching GPD)
  terminal = {
    colors = {
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor = "#f5e0dc";

      # Complete Catppuccin Mocha palette
      color0 = "#45475a";  # black
      color1 = "#f38ba8";  # red
      color2 = "#a6e3a1";  # green
      color3 = "#f9e2af";  # yellow
      color4 = "#89b4fa";  # blue
      color5 = "#f5c2e7";  # magenta
      color6 = "#94e2d5";  # cyan
      color7 = "#bac2de";  # white
      color8 = "#585b70";  # bright black
      color9 = "#f38ba8";  # bright red
      color10 = "#a6e3a1"; # bright green
      color11 = "#f9e2af"; # bright yellow
      color12 = "#89b4fa"; # bright blue
      color13 = "#f5c2e7"; # bright magenta
      color14 = "#94e2d5"; # bright cyan
      color15 = "#a6adc8"; # bright white
    };
    font = "JetBrainsMono Nerd Font";
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    configure = {
      customRC = ''
        " Basic settings
        set number
        set relativenumber
        set expandtab
        set tabstop=2
        set shiftwidth=2
        set smartindent
        set wrap
        set ignorecase
        set smartcase
        set termguicolors
        set clipboard=unnamedplus

        " Better navigation
        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l

        " Catppuccin theme
        colorscheme catppuccin-mocha
      '';
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "a";
    userEmail = "pixel9pro@nix";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };

  # Set timezone (same as GPD)
  time.timeZone = "Europe/London";

  # System version
  system.stateVersion = "24.05";
}