{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.security.secretsManagement;
in
{
  options.custom.system.security.secretsManagement = {
    enable = mkEnableOption "sops-nix secrets management";

    defaultSopsFile = mkOption {
      type = types.path;
      default = ./../../secrets/secrets.yaml;
      description = "Default sops secrets file";
    };
  };

  config = mkIf cfg.enable {
    # sops-nix configuration
    sops = {
      # Age key for decryption (will be generated on first run)
      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };

      # Only set defaultSopsFile if it exists
      defaultSopsFile = mkIf (builtins.pathExists cfg.defaultSopsFile) cfg.defaultSopsFile;

      # Secrets will be defined when secrets.yaml is created
      # secrets = {};
    };

    # Install sops for manual secret editing
    environment.systemPackages = with pkgs; [
      sops
      age
    ];

    # Documentation - now part of unified system info
    # See modules/system/default.nix for the combined display
  };
}
