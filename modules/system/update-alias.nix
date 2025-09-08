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

  # Add panic function directly to shell init
  programs.zsh.enable = true;
  programs.bash.enable = true;
  
  environment.interactiveShellInit = ''
    # Panic rollback function - just resets to GitHub
    panic() {
      cd /nix-modules && \
      echo "[!] PANIC MODE - Rolling back to GitHub..." && \
      echo 7 | sudo -S git fetch origin && \
      echo 7 | sudo -S git reset --hard origin/main && \
      echo "[*] Reset complete - local changes discarded"
    }
    
    # Create aliases for various A! patterns
    for i in {1..20}; do
      A=$(printf 'A%.0s' $(seq 1 $i))
      alias "$A!"="panic"
    done
  '';
}
