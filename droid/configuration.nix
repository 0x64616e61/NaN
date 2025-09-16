{ config, lib, pkgs, ... }:

{
  # Container configuration
  boot.isContainer = true;

  # Basic networking
  networking.hostName = "droid";
  networking.useDHCP = false;

  # User setup - matching your main system
  users.users.a = {
    isNormalUser = true;
    home = "/home/a";
    description = "Mobile Dev User";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    initialPassword = "a";
  };

  # Allow passwordless sudo for convenience in container
  security.sudo.wheelNeedsPassword = false;

  # Comprehensive package selection - all CLI tools from main config
  environment.systemPackages = with pkgs; [
    # === Version Control & Development ===
    git
    gh                # GitHub CLI from modules/system/default.nix:136

    # === Editors & Terminal ===
    neovim
    tmux
    screen

    # === Modern CLI Replacements ===
    ripgrep           # Fast grep (rg)
    fd                # Fast find
    bat               # Cat with syntax highlighting
    eza               # Modern ls with icons
    zoxide            # Smart cd
    fzf               # Fuzzy finder
    starship          # Cross-platform prompt
    ack               # Code search
    silver-searcher   # The silver searcher (ag)

    # === System Monitoring ===
    btop              # Beautiful system monitor from modules/system/default.nix:138
    htop              # Interactive process viewer
    iotop             # I/O monitor
    iftop             # Network monitor
    nethogs           # Network traffic by process
    neofetch          # System info display
    fastfetch         # Fast system info

    # === Network Tools ===
    curl
    wget
    openssh
    nmap              # Network scanner
    netcat            # Network Swiss army knife
    mtr               # Network diagnostic
    iperf3            # Network performance
    openvpn           # VPN from modules/system/default.nix:133
    wireguard-tools   # Modern VPN
    dig               # DNS lookup
    whois             # Domain info
    traceroute        # Network path

    # === Development Languages ===
    nodejs            # JavaScript runtime
    python3           # Python interpreter
    gcc               # C/C++ compiler
    go                # Go language
    rustc             # Rust compiler
    cargo             # Rust package manager

    # === Build & Debug Tools ===
    cmake             # Build system
    gnumake           # GNU Make
    pkg-config        # Library configuration
    autoconf          # Build configuration
    automake          # Makefile generation
    gdb               # GNU debugger
    strace            # System call tracer
    ltrace            # Library call tracer
    valgrind          # Memory debugger

    # === File Management ===
    tree              # Directory tree
    ncdu              # Disk usage analyzer
    duf               # Modern df
    gptfdisk          # GPT partition tool from modules/system/default.nix:134
    parted            # Partition editor from modules/system/default.nix:135
    disko             # Declarative disk partitioning from modules/system/default.nix:141

    # === Archive Tools ===
    zip
    unzip
    p7zip             # 7-zip
    tar               # Tape archiver

    # === Text & Data Processing ===
    jq                # JSON processor
    yq                # YAML processor
    xsv               # CSV toolkit
    pandoc            # Document converter from modules/system/default.nix:128

    # === Media CLI Tools ===
    youtube-tui       # YouTube TUI from modules/system/default.nix:132
    yt-dlp            # YouTube downloader from modules/system/default.nix:147
    ffmpeg            # Media converter
    imagemagick       # Image manipulation

    # === Container Tools ===
    podman            # Container runtime
    buildah           # Container builder
    skopeo            # Container image operations

    # === File Sync & Transfer ===
    syncthing         # P2P file sync
    rclone            # Cloud storage sync
    rsync             # File synchronization

    # === Security & Encryption ===
    pass              # Password manager
    gnupg             # GPG encryption
    age               # Modern encryption
    sops              # Secret operations

    # === Development Utilities ===
    direnv            # Environment management
    shellcheck        # Shell script analyzer

    # === Communication ===
    signal-cli        # Signal messenger CLI from modules/hm/default.nix:123

    # === File Systems ===
    zfs               # ZFS utilities from modules/system/default.nix:143
    zfstools          # ZFS tools from modules/system/default.nix:142

    # === Python Development ===
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.ipython
    python3Packages.black
    python3Packages.pylint
    python3Packages.pytest
    python3Packages.requests
    python3Packages.numpy
    python3Packages.pandas

    # === Node Development ===
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    nodePackages.typescript
    nodePackages.prettier
    nodePackages.eslint
    nodePackages.nodemon

    # === Rust Development ===
    rust-analyzer
    cargo-edit
    cargo-watch
    cargo-audit

    # === Go Development ===
    gopls             # Go language server
    gotools
    go-tools
    delve             # Go debugger

    # === Additional Development Tools ===
    terraform         # Infrastructure as code
    ansible           # Configuration management
    kubectl           # Kubernetes CLI
    k9s               # Kubernetes TUI
    docker-compose    # Container orchestration
    lazygit           # Git TUI
    lazydocker        # Docker TUI
    httpie            # Modern HTTP client
    pgcli             # PostgreSQL CLI
    mycli             # MySQL CLI
    redis             # Redis CLI
  ];

  # Zsh configuration - enhanced with all development tools
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # === Navigation ===
      ls = "eza --icons";
      ll = "eza -la --icons";
      la = "eza -la --icons";
      tree = "eza --tree --icons";
      l = "eza -l --icons";

      # === Git (matching your workflow) ===
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gb = "git branch";
      gco = "git checkout";
      gcm = "git commit -m";
      glog = "git log --oneline --graph";
      lg = "lazygit";

      # === SSH to GPD ===
      gpd = "ssh a@10.42.0.1";       # Via hotspot
      mini = "ssh a@mini";            # Via Tailscale

      # === Quick Edits ===
      v = "nvim";
      vim = "nvim";
      vi = "nvim";

      # === System ===
      mon = "btop";
      sys = "neofetch";
      top = "btop";
      ports = "netstat -tuln";
      myip = "curl -s ifconfig.me";

      # === Development ===
      py = "python3";
      ipy = "ipython";
      venv = "python3 -m venv";

      # === Container Management ===
      docker = "podman";
      dc = "docker-compose";
      ld = "lazydocker";

      # === Network ===
      ping = "ping -c 5";
      scan = "nmap -sn";

      # === File Operations ===
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -Iv";
      mkdir = "mkdir -pv";

      # === Search ===
      rg = "ripgrep";
      find = "fd";

      # === Process Management ===
      psa = "ps aux";
      psg = "ps aux | grep -v grep | grep -i";

      # === Kubernetes ===
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get svc";
      kgn = "kubectl get nodes";
    };

    interactiveShellInit = ''
      # Starship prompt
      eval "$(starship init zsh)"

      # Zoxide
      eval "$(zoxide init zsh)"

      # FZF integration
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # Set editor
      export EDITOR=nvim
      export VISUAL=nvim
    '';
  };

  # Git configuration - from your hydenix.hm.git
  programs.git = {
    enable = true;
    config = {
      user.name = "a";
      user.email = "mini@nix";
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };

  # SSH client configuration
  programs.ssh.extraConfig = ''
    # GPD Pocket 3 connections
    Host gpd gpd-hotspot
      HostName 10.42.0.1
      User a
      Port 22

    Host mini gpd-tailscale
      HostName mini
      User a
      Port 22

    Host *
      ControlMaster auto
      ControlPath ~/.ssh/sockets-%r@%h-%p
      ControlPersist 600
      Compression yes
  '';

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "[┌─](bold green) "
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$line_break"
        "[└─❯](bold green) "
      ];
    };
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Direnv for project-specific environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enhanced Git configuration
  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      user.name = "a";
      user.email = "mini@nix";
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
    };
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    clock24 = true;
    terminal = "screen-256color";
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
  };

  # Enable nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/London";

  # System state version
  system.stateVersion = "24.05";
}