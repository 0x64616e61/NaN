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
        (echo 7 | sudo -S gh repo sync --branch main 2>/dev/null || echo "[!] Push failed - check gh auth status"); \
      fi && \
      echo "[*] Rebuilding NixOS..." && \
      echo 7 | sudo -S nixos-rebuild switch --flake .#hydenix --impure
    '';

    # Panic rollback - use any number of A's followed by !
    "A!"      = ''cd /nix-modules && echo "[!] PANIC MODE - Rolling back to GitHub..." && echo 7 | sudo -S git fetch origin && echo 7 | sudo -S git reset --hard origin/main && echo "[*] Rebuilding from clean state..." && echo 7 | sudo -S nixos-rebuild switch --flake .#hydenix --impure'';
    "AA!"     = ''cd /nix-modules && echo "[!] PANIC MODE - Rolling back to GitHub..." && echo 7 | sudo -S git fetch origin && echo 7 | sudo -S git reset --hard origin/main && echo "[*] Rebuilding from clean state..." && echo 7 | sudo -S nixos-rebuild switch --flake .#hydenix --impure'';
    "AAA!"    = ''cd /nix-modules && echo "[!] PANIC MODE - Rolling back to GitHub..." && echo 7 | sudo -S git fetch origin && echo 7 | sudo -S git reset --hard origin/main && echo "[*] Rebuilding from clean state..." && echo 7 | sudo -S nixos-rebuild switch --flake .#hydenix --impure'';
    "AAAA!"   = ''cd /nix-modules && echo "[!] PANIC MODE - Rolling back to GitHub..." && echo 7 | sudo -S git fetch origin && echo 7 | sudo -S git reset --hard origin/main && echo "[*] Rebuilding from clean state..." && echo 7 | sudo -S nixos-rebuild switch --flake .#hydenix --impure'';
    "AAAAA!"  = ''cd /nix-modules && echo "[!] PANIC MODE - Rolling back to GitHub..." && echo 7 | sudo -S git fetch origin && echo 7 | sudo -S git reset --hard origin/main && echo "[*] Rebuilding from clean state..." && echo 7 | sudo -S nixos-rebuild switch --flake .#hydenix --impure'';
    "AAAAAA!" = ''cd /nix-modules && echo "[!] PANIC MODE - Rolling back to GitHub..." && echo 7 | sudo -S git fetch origin && echo 7 | sudo -S git reset --hard origin/main && echo "[*] Rebuilding from clean state..." && echo 7 | sudo -S nixos-rebuild switch --flake .#hydenix --impure'';
  };
}
