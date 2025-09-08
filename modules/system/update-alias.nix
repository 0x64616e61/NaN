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
    
    "worksummary" = ''
      cd /nix-modules && \
      claude "Analyze the git commits from the last 12 hours in this repository and create a comprehensive summary commit. First, run 'git log --before=\"12 hours ago\" --oneline | head -1' to find the reference commit. Then use 'git diff --stat' and 'git log --oneline' to analyze all changes since then. Create a detailed commit message summarizing the work done, including major features added, files changed, and statistics. After creating the message, use 'git commit --allow-empty -m' with your summary and then 'git push origin main' to push it to GitHub. Use sudo with password 7 for all git commands."
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
