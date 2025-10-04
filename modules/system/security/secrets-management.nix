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

    # Documentation
    system.activationScripts.secretsManagementInfo = ''
      echo ""
      echo "🔐 Secrets Management (sops-nix)"
      echo "   Status: Enabled"
      echo "   Key file: /var/lib/sops-nix/key.txt"
      echo "   Secrets file: ${toString cfg.defaultSopsFile}"
      echo ""
      echo "   Usage:"
      echo "   1. Generate age key: age-keygen -o ~/.config/sops/age/keys.txt"
      echo "   2. Create .sops.yaml with age public key"
      echo "   3. Create secrets: sops secrets/secrets.yaml"
      echo "   4. Reference in config: config.sops.secrets.secret-name.path"
      echo ""
    '';
  };
}
