{ config, lib, pkgs, ... }:

{
  # Basic system packages
  environment.packages = with pkgs; [
    # Core utilities
    git
    neovim
    tmux
    openssh

    # Modern CLI tools
    ripgrep
    fd
    bat
    eza
    zoxide
    starship
    fzf

    # Development tools
    nodejs
    python3
    gcc

    # Network tools
    curl
    wget
    nmap

    # File management
    syncthing
    rclone

    # System monitoring
    htop
    btop
    neofetch
  ];

  # Shell configuration
  user.shell = "${pkgs.zsh}/bin/zsh";

  # Zsh configuration
  programs.zsh = {
    enable = true;
    shellAliases = {
      # Navigation
      ls = "eza --icons";
      ll = "eza -la --icons";
      tree = "eza --tree --icons";

      # Git
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";

      # Nix
      rebuild = "nix-on-droid switch --flake .#pixel9pro";
      update = "nix flake update";

      # SSH to GPD
      gpd = "ssh a@10.42.0.1";  # When connected to GPD hotspot
    };

    initExtra = ''
      # Starship prompt
      eval "$(starship init zsh)"

      # Zoxide
      eval "$(zoxide init zsh)"

      # FZF
      source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
    '';
  };

  # SSH client configuration
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host gpd
        HostName 10.42.0.1
        User a
        Port 22

      Host gpd-tailscale
        HostName mini
        User a
        Port 22
    '';
  };

  # Syncthing for file sync with GPD
  services.syncthing = {
    enable = true;
    dataDir = "/data/data/com.termux.nix/files/home/Sync";
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

  # Terminal settings
  terminal = {
    colors = {
      # Catppuccin Mocha theme
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      cursor = "#f5e0dc";
    };
    font = "JetBrainsMono Nerd Font";
  };

  # Set timezone (same as GPD)
  time.timeZone = "Europe/London";

  # System version
  system.stateVersion = "24.05";
}