{ config, lib, pkgs, ... }:

{
  # Minimal NixOS container configuration
  boot.isContainer = true;

  networking.hostName = "mobile";
  networking.useDHCP = false;

  # Single user setup
  users.users.dev = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    initialPassword = "dev";
  };

  security.sudo.wheelNeedsPassword = false;

  # Core packages only - can be extended from GitHub
  environment.systemPackages = with pkgs; [
    # Essentials
    git
    neovim
    tmux

    # Modern CLI
    ripgrep
    fd
    bat
    eza
    zoxide
    starship
    fzf

    # Dev tools
    nodejs
    python3
    gh

    # Network
    curl
    wget
    openssh

    # System
    btop
    neofetch
  ];

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # Navigation
      ls = "eza --icons";
      ll = "eza -la --icons";

      # Git
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";

      # Quick SSH
      gpd = "ssh a@10.42.0.1";
      mini = "ssh a@mini";

      # Update from GitHub
      update-config = ''
        curl -L https://raw.githubusercontent.com/0x64616e61/nix-modules/production/terminal-vm/minimal-nixos/config.nix > /tmp/config.nix && \
        echo "Config downloaded. To apply: nixos-rebuild switch"
      '';
    };

    interactiveShellInit = ''
      eval "$(starship init zsh)"
      eval "$(zoxide init zsh)"
    '';
  };

  programs.git = {
    enable = true;
    config = {
      user.name = "dev";
      user.email = "dev@mobile";
      init.defaultBranch = "main";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  time.timeZone = "Europe/London";
  system.stateVersion = "24.05";
}