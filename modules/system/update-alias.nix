{ config, lib, pkgs, ... }:

{
  # Shell alias for convenient system updates
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
  };
}
