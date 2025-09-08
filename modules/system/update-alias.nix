{ config, lib, pkgs, ... }:

{
  # Shell aliases for convenient system updates
  environment.shellAliases = {
    "update!" = ''
      cd /nix-modules && \
      echo "[*] Checking for changes..." && \
      if [ -n "$(echo 7 | sudo -S git status --porcelain 2>/dev/null)" ]; then \
        echo "[+] Committing changes..." && \
        echo 7 | sudo -S git add -A && \
        echo 7 | sudo -S git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')" && \
        echo "[>] Pushing to GitHub..." && \
        (echo 7 | sudo -S git push origin main 2>/dev/null || echo "[!] Push failed - check git credentials"); \
      fi && \
      echo "[*] Rebuilding NixOS..." && \
      echo 7 | sudo -S nixos-rebuild switch --flake .#hydenix --impure
    '';
  };

  # Shell function for panic rollback - matches any number of A's followed by !
  programs.zsh.interactiveShellInit = ''
    # Command not found handler that checks for panic commands
    command_not_found_handler() {
      if [[ "$1" =~ ^A+!$ ]]; then
        cd /nix-modules && \
        echo "[!] PANIC MODE - Rolling back to GitHub..." && \
        echo 7 | sudo -S git fetch origin && \
        echo 7 | sudo -S git reset --hard origin/main && \
        echo "[*] Rebuilding from clean state..." && \
        echo 7 | sudo -S nixos-rebuild switch --flake .#hydenix --impure
      else
        # Default command not found message
        echo "zsh: command not found: $1" >&2
        return 127
      fi
    }
  '';

  programs.bash.interactiveShellInit = ''
    # Command not found handler for bash
    command_not_found_handle() {
      if [[ "$1" =~ ^A+!$ ]]; then
        cd /nix-modules && \
        echo "[!] PANIC MODE - Rolling back to GitHub..." && \
        echo 7 | sudo -S git fetch origin && \
        echo 7 | sudo -S git reset --hard origin/main && \
        echo "[*] Rebuilding from clean state..." && \
        echo 7 | sudo -S nixos-rebuild switch --flake .#hydenix --impure
      else
        # Default command not found message
        echo "bash: $1: command not found" >&2
        return 127
      fi
    }
  '';
}
