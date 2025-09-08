{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.email;
in
{
  options.custom.system.packages.email = {
    enable = mkEnableOption "email clients and tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      protonmail-bridge  # Proton Mail Bridge
      thunderbird        # Thunderbird email client
      pass              # Password manager that works with ProtonMail Bridge
      gnupg             # Required for pass
      cacert            # CA certificates for SSL/TLS
      openssl           # OpenSSL for certificate management
    ];
    
    # GnuPG agent is already enabled by hydenix
    
    # Set SSL certificate environment variables for ProtonMail Bridge
    environment.variables = {
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    };
  };
}