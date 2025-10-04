{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.security.hardening;
in
{
  options.custom.system.security.hardening = {
    enable = mkEnableOption "System security hardening";

    restrictSSH = mkOption {
      type = types.bool;
      default = true;
      description = "Restrict SSH to key-based auth only, disable root login";
    };

    closeGamingPorts = mkOption {
      type = types.bool;
      default = true;
      description = "Close Steam/gaming ports (27015, 27036, etc.)";
    };
  };

  config = mkIf cfg.enable {
    # SSH Hardening
    services.openssh = mkIf cfg.restrictSSH {
      settings = {
        PasswordAuthentication = false;  # Only SSH keys
        PermitRootLogin = "no";          # No root login
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
      };
      # Limit SSH to specific IP ranges (adjust as needed)
      # listenAddresses = [
      #   { addr = "192.168.1.0/24"; port = 22; }
      # ];
    };

    # Firewall Hardening
    networking.firewall = {
      enable = true;

      # Log refused connections
      logRefusedConnections = true;
      logRefusedPackets = false;  # Too verbose
    };

    # Additional security hardening
    security = {
      # Protect kernel from user modification
      protectKernelImage = true;

      # Lock kernel modules after boot
      lockKernelModules = false;  # Set to true if not compiling custom modules

      # Restrict ptrace to same user processes
      allowUserNamespaces = true;  # Needed for nix-shell

      # Enable AppArmor
      apparmor = {
        enable = true;
        killUnconfinedConfinables = true;
        packages = [ pkgs.apparmor-profiles ];
      };

      # Polkit security
      polkit.enable = true;

      # Sudo security
      sudo = {
        enable = true;
        execWheelOnly = true;  # Only wheel group can sudo
        wheelNeedsPassword = true;
      };
    };

    # Audit logging
    security.audit.enable = true;
    security.auditd.enable = true;

    # Restrict dmesg to root
    boot.kernel.sysctl = {
      "kernel.dmesg_restrict" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
      "net.core.bpf_jit_harden" = 2;
    };

    # Git commit signing
    programs.git = {
      enable = true;
      config = {
        commit.gpgsign = true;
        tag.gpgsign = true;
        user = {
          signingkey = "~/.ssh/id_ed25519.pub";  # Use SSH key for signing
        };
        gpg.format = "ssh";
      };
    };

    # GPG and SSH tools
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}

