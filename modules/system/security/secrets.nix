{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.security.secrets;
in
{
  options.custom.system.security.secrets = {
    enable = mkEnableOption "secret service configuration";
    
    provider = mkOption {
      type = types.enum [ "keepassxc" "gnome-keyring" "none" ];
      default = "keepassxc";
      description = "Secret service provider to use";
    };
    
    keepassxc = {
      package = mkOption {
        type = types.package;
        default = pkgs.keepassxc;
        description = "KeePassXC package to use";
      };
      
      enableDbus = mkOption {
        type = types.bool;
        default = true;
        description = "Enable D-Bus integration for KeePassXC";
      };
    };
    
    gnomeKeyring = {
      components = mkOption {
        type = types.listOf types.str;
        default = [ "pkcs11" "secrets" "ssh" ];
        description = "Components to enable for gnome-keyring";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Common configuration
    {
      services.dbus.enable = true;
      environment.systemPackages = [ pkgs.libsecret ];
    }
    
    # KeePassXC configuration
    (mkIf (cfg.provider == "keepassxc") {
      environment.systemPackages = [ cfg.keepassxc.package ];
      services.dbus.packages = mkIf cfg.keepassxc.enableDbus [ cfg.keepassxc.package ];
    })
    
    # GNOME Keyring configuration
    (mkIf (cfg.provider == "gnome-keyring") {
      services.gnome.gnome-keyring.enable = true;
      programs.seahorse.enable = true;
      environment.systemPackages = [ pkgs.gnome-keyring ];

      # PAM configuration to auto-start keyring on login
      security.pam.services.login.enableGnomeKeyring = true;
      security.pam.services.sddm.enableGnomeKeyring = true;
    })
  ]);
}