{ config, lib, pkgs, ... }:

{
  # Absolute minimal configuration for initial bootstrap
  # This should complete quickly and get you a working shell

  # Just the shell
  user.shell = "${pkgs.bash}/bin/bash";

  # Only essential packages for bootstrap
  environment.packages = with pkgs; [
    git
    vim
    curl
  ];

  # Basic nix settings
  nix = {
    extraConfig = ''
      experimental-features = nix-command flakes
    '';
  };

  # System version
  system.stateVersion = "24.05";
}