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

  # Packages - extracted from your existing configs
  environment.systemPackages = with pkgs; [
    # === Core Development (from your system) ===
    git
    neovim
    tmux
    gh                # From modules/system/default.nix:136

    # === Modern CLI (from Hydenix base) ===
    ripgrep           # Fast grep
    fd                # Fast find
    bat               # Cat with syntax highlighting
    eza               # Modern ls
    zoxide            # Smart cd
    fzf               # Fuzzy finder
    starship          # Cross-platform prompt

    # === System Tools (from your system) ===
    btop              # From modules/system/default.nix:138
    htop
    neofetch

    # === Network Tools ===
    curl
    wget
    openssh
    nmap

    # === Development Languages ===
    nodejs
    python3
    gcc

    # === File Operations ===
    tree
    ncdu
    unzip
    zip

    # === Text Processing ===
    jq
    yq

    # === File Sync ===
    syncthing
    rclone
  ];

  # Zsh configuration - matching your main setup style
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

      # === Git (matching your workflow) ===
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gb = "git branch";
      gco = "git checkout";

      # === SSH to GPD ===
      gpd = "ssh a@10.42.0.1";       # Via hotspot
      mini = "ssh a@mini";            # Via Tailscale

      # === Quick Edits ===
      v = "nvim";
      vim = "nvim";

      # === System ===
      mon = "btop";
      sys = "neofetch";
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

  # Enable nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/London";

  # System state version
  system.stateVersion = "24.05";
}