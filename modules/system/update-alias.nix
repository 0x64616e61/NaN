{ config, lib, pkgs, ... }:

{
  # Systemd services for privileged operations (replaces hardcoded passwords)
  systemd.services.nixos-update = {
    description = "NixOS system update with git sync";
    script = ''
      cd /nix-modules
      echo "[*] Checking for changes..."

      if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        echo "[+] Committing changes..."
        git add -A
        git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"

        echo "[>] Pushing to GitHub..."
        if ! git push origin main 2>&1; then
          echo "❌ Push failed. Troubleshooting steps:"
          echo "  1. Check GitHub CLI authentication: gh auth status"
          echo "  2. Verify remote is accessible: git remote -v"
          echo "  3. Test SSH connection: ssh -T git@github.com"
          echo "  4. Re-authenticate if needed: gh auth login"
          exit 1
        fi
      fi

      echo "[*] Rebuilding NixOS..."
      nixos-rebuild switch --flake .#NaN --impure || {
        echo "❌ Rebuild failed. Check errors above."
        echo "  Rollback: sudo nixos-rebuild switch --rollback"
        echo "  Debug: journalctl -xe"
        exit 1
      }
    '';
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/nix-modules";
    };
  };

  # Polkit rules to allow wheel group to run update service without password
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.isInGroup("wheel") &&
          action.lookup("unit") == "nixos-update.service") {
        return polkit.Result.YES;
      }
    });
  '';

  # Shell aliases for convenient system updates (now secure)
  environment.shellAliases = {
    "update!" = ''
      sudo systemctl start nixos-update.service && \
      sudo journalctl -u nixos-update.service -n 50 --no-pager
    '';

    # Simpler rebuild aliases with better error handling
    "rebuild-test" = ''
      cd /nix-modules && sudo nixos-rebuild test --flake .#NaN --impure --show-trace
    '';

    "rebuild-dry" = ''
      cd /nix-modules && sudo nixos-rebuild dry-build --flake .#NaN --impure
    '';

    "rebuild-diff" = ''
      cd /nix-modules && sudo nixos-rebuild build --flake .#NaN --impure && \
      ${pkgs.nvd}/bin/nvd diff /run/current-system result
    '';

    "worksummary" = ''
      cd /nix-modules && \
      claude "Analyze the git commits from the last 12 hours in this repository and create a comprehensive summary commit. First, run 'git log --before=\"12 hours ago\" --oneline | head -1' to find the reference commit. Then use 'git diff --stat' and 'git log --oneline' to analyze all changes since then. Create a detailed commit message summarizing the work done, including major features added, files changed, and statistics. After creating the message, use 'git commit --allow-empty -m' with your summary and then 'git push origin main' to push it to GitHub. Use sudo for all git commands but let systemd handle authentication."
    '';

    # Help alias for command discovery
    "help-aliases" = ''
      cat << 'EOF'
📋 NixOS Configuration Aliases

SYSTEM MANAGEMENT:
  update!          - Commit, push, and rebuild system (secure via systemd)
  rebuild-test     - Test configuration without switching
  rebuild-dry      - Dry-run to see what would change
  rebuild-diff     - Build and compare with current system
  panic / A!       - Emergency rollback to GitHub state (with confirmation)
  worksummary      - Generate AI summary of recent commits

DISPLAY:
  displays         - List all displays
  rot              - Restart rotation service

POWER:
  power-profile    - Switch power mode (performance/powersave)
  battery-status   - Show battery health and status

CLAUDE AI:
  cc               - Shortcut for 'claude' command
  claude-check     - Verify Claude installation

HELP:
  help-aliases     - Show this message

For full documentation: cat /nix-modules/docs/NAVIGATION.md
EOF
    '';
  };

  # Add panic function directly to shell init
  programs.zsh.enable = true;
  programs.bash.enable = true;

  environment.interactiveShellInit = ''
    # Panic rollback function with rate limiting and backup
    panic() {
      PANIC_LOCKFILE="/tmp/panic-cooldown"
      COOLDOWN=30  # 30 second cooldown

      # Check for cooldown
      if [ -f "$PANIC_LOCKFILE" ]; then
        LAST_PANIC=$(stat -c %Y "$PANIC_LOCKFILE")
        NOW=$(date +%s)
        ELAPSED=$((NOW - LAST_PANIC))

        if [ $ELAPSED -lt $COOLDOWN ]; then
          REMAINING=$((COOLDOWN - ELAPSED))
          echo "⏱️  Panic on cooldown. Wait ''${REMAINING}s to prevent accidental spam."
          return 1
        fi
      fi

      # Confirmation prompt
      echo "⚠️  PANIC MODE - This will discard all local changes!"
      echo "   A backup branch will be created first."
      read -p "   Continue? [y/N] " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        return 1
      fi

      # Backup before panic
      BACKUP_BRANCH="panic-backup-$(date +%s)"
      cd /nix-modules || return 1

      echo "[!] Creating backup branch: $BACKUP_BRANCH"
      if git branch "$BACKUP_BRANCH" 2>/dev/null; then
        echo "[✓] Backup created"
      else
        echo "[!] Warning: Could not create backup branch"
      fi

      echo "[!] Rolling back to GitHub..."
      if sudo git fetch origin && sudo git reset --hard origin/main; then
        echo "[✓] Reset complete - local changes saved in branch '$BACKUP_BRANCH'"
        touch "$PANIC_LOCKFILE"
      else
        echo "❌ Panic rollback failed!"
        echo "   Try manually: cd /nix-modules && sudo git reset --hard origin/main"
        return 1
      fi
    }

    # Create aliases for various A! patterns (limit to 5 to reduce DoS risk)
    for i in {1..5}; do
      A=$(printf 'A%.0s' $(seq 1 $i))
      alias "$A!"="panic"
    done
  '';
}
