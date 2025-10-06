{ config, lib, pkgs, ... }:
# System Backup Configuration Module
#
# This module provides automated backup capabilities using restic for the grOSs system.
# Restic is a fast, secure, and efficient backup program with deduplication and encryption.
#
# Features:
# - Automated daily backups via systemd timers
# - Encrypted backups with AES-256
# - Deduplication to save space
# - Multiple backend support (local, S3, B2, etc.)
# - Automatic retention policy (keep last 7 daily, 4 weekly, 12 monthly)
#
# Configuration example:
#   custom.system.backup = {
#     enable = true;
#     repository = "/mnt/backup/restic";
#     passwordFile = "/etc/nixos/secrets/restic-password";
#     paths = [
#       "/home/a"
#       "/etc/nixos"
#     ];
#   };
#
# Initial setup:
#   1. Create password file: echo "secure-password" > /etc/nixos/secrets/restic-password
#   2. Initialize repository: sudo restic -r /mnt/backup/restic init
#   3. Enable backup service: Set enable = true in configuration
#   4. Test backup: sudo systemctl start restic-backup.service

with lib;

let
  cfg = config.custom.system.backup;
in
{
  options.custom.system.backup = {
    enable = mkEnableOption "automated system backups with restic";

    repository = mkOption {
      type = types.str;
      default = "/var/backup/restic";
      example = "s3:s3.amazonaws.com/bucket-name";
      description = ''
        Restic repository location. Can be:
        - Local path: /mnt/backup/restic
        - S3: s3:s3.amazonaws.com/bucket-name
        - B2: b2:bucket-name
        - SFTP: sftp:user@host:/path
        - REST: rest:https://backup.example.com/
      '';
    };

    passwordFile = mkOption {
      type = types.str;
      default = "/etc/nixos/secrets/restic-password";
      description = ''
        Path to file containing the restic repository password.
        This file should be readable only by root (chmod 600).
        Create with: echo "your-password" > /etc/nixos/secrets/restic-password
      '';
    };

    paths = mkOption {
      type = types.listOf types.str;
      default = [
        "/home"
        "/etc/nixos"
        "/var/lib"
      ];
      example = [
        "/home/a"
        "/etc/nixos"
        "/var/lib/docker"
      ];
      description = "List of paths to include in backups";
    };

    exclude = mkOption {
      type = types.listOf types.str;
      default = [
        "/home/*/.cache"
        "/home/*/.local/share/Trash"
        "/home/*/Downloads"
        "*.tmp"
        "*.log"
      ];
      description = "List of patterns to exclude from backups";
    };

    timerConfig = mkOption {
      type = types.attrs;
      default = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      description = "Systemd timer configuration for backup schedule";
    };

    pruneOpts = mkOption {
      type = types.listOf types.str;
      default = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
        "--keep-yearly 3"
      ];
      description = "Retention policy for old backups";
    };

    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [
        "--verbose"
        "--exclude-caches"
      ];
      description = "Additional restic backup options";
    };
  };

  config = mkIf cfg.enable {
    # Install restic
    environment.systemPackages = [ pkgs.restic ];

    # Systemd service for backups
    systemd.services.restic-backup = {
      description = "Restic backup service for grOSs";

      serviceConfig = {
        Type = "oneshot";
        User = "root";

        # Security hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [ cfg.repository ];

        # Environment
        Environment = [
          "RESTIC_REPOSITORY=${cfg.repository}"
          "RESTIC_PASSWORD_FILE=${cfg.passwordFile}"
        ];
      };

      script = ''
        # Pre-backup checks
        if [ ! -f "${cfg.passwordFile}" ]; then
          echo "ERROR: Password file not found: ${cfg.passwordFile}"
          echo "Create with: echo 'your-password' > ${cfg.passwordFile}"
          exit 1
        fi

        # Check if repository is initialized
        if ! ${pkgs.restic}/bin/restic snapshots >/dev/null 2>&1; then
          echo "ERROR: Restic repository not initialized at ${cfg.repository}"
          echo "Initialize with: restic -r ${cfg.repository} init"
          exit 1
        fi

        # Perform backup
        echo "Starting backup to ${cfg.repository}..."
        ${pkgs.restic}/bin/restic backup \
          ${concatStringsSep " " (map (path: ''"${path}"'') cfg.paths)} \
          ${concatStringsSep " " (map (pattern: ''--exclude "${pattern}"'') cfg.exclude)} \
          ${concatStringsSep " " cfg.extraOptions} \
          --tag "grOSs-system" \
          --tag "$(hostname)" \
          --host "$(hostname)"

        # Prune old backups
        echo "Pruning old backups..."
        ${pkgs.restic}/bin/restic forget \
          ${concatStringsSep " " cfg.pruneOpts} \
          --prune

        # Check repository integrity (monthly)
        if [ $(date +%d) -eq 01 ]; then
          echo "Running monthly repository check..."
          ${pkgs.restic}/bin/restic check
        fi

        echo "Backup completed successfully"
      '';

      # Send notification on failure
      onFailure = [ "backup-failure-notification.service" ];
    };

    # Notification service for backup failures
    systemd.services.backup-failure-notification = {
      description = "Notify on backup failure";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        # Try to send notification to user
        if command -v ${pkgs.libnotify}/bin/notify-send >/dev/null 2>&1; then
          DISPLAY=:0 ${pkgs.libnotify}/bin/notify-send \
            -u critical \
            "Backup Failed" \
            "System backup failed. Check journalctl -u restic-backup for details."
        fi

        # Log to systemd journal
        ${pkgs.systemd}/bin/systemd-cat -t "backup-failure" -p err \
          echo "Backup service failed. Check logs with: journalctl -u restic-backup"
      '';
    };

    # Systemd timer for scheduled backups
    systemd.timers.restic-backup = {
      description = "Timer for restic backup service";
      wantedBy = [ "timers.target" ];
      timerConfig = cfg.timerConfig;
    };

    # Shell aliases for manual backup operations
    environment.shellAliases = {
      backup-now = "sudo systemctl start restic-backup.service";
      backup-status = "sudo systemctl status restic-backup.service";
      backup-logs = "sudo journalctl -u restic-backup -f";
      backup-list = "sudo restic -r ${cfg.repository} snapshots";
      backup-restore = "sudo restic -r ${cfg.repository} restore latest --target /tmp/restore";
    };

    # Ensure backup directory exists for local repositories
    systemd.tmpfiles.rules = mkIf (hasPrefix "/" cfg.repository) [
      "d ${cfg.repository} 0700 root root -"
    ];
  };
}
