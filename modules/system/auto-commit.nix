# Auto-commit and push changes to GitHub on rebuild
{ config, lib, pkgs, ... }:

{
  # Create a PRE-activation script that runs BEFORE rebuild to fix dirty git tree
  system.activationScripts.autoCommitChanges = lib.mkBefore ''
    echo "Checking for uncommitted changes in /nix-modules..."
    
    # Change to the nix-modules directory
    cd /nix-modules
    
    # Check if there are any changes
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      echo "Found uncommitted changes, committing to fix dirty git tree..."
      
      # Configure git if needed
      git config user.email "noreply@github.com" 2>/dev/null || true
      git config user.name "NixOS Auto-Commit" 2>/dev/null || true
      
      # Add all changes
      git add -A
      
      # Create commit message with timestamp
      TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
      git commit -m "Auto-commit: NixOS rebuild at $TIMESTAMP" || {
        echo "Failed to commit changes"
      }
      
      # Try to push using gh CLI from nixpkgs
      echo "Pushing changes to GitHub..."
      if command -v gh &> /dev/null; then
        gh repo sync --branch main 2>/dev/null || {
          echo "Failed to push (may need 'gh auth login')"
        }
      elif [ -f "${pkgs.gh}/bin/gh" ]; then
        ${pkgs.gh}/bin/gh repo sync --branch main 2>/dev/null || {
          echo "Failed to push (may need 'gh auth login')"
        }
      else
        echo "gh CLI not available, skipping push"
      fi
      
      echo "Git tree is now clean"
    else
      echo "No uncommitted changes found"
    fi
  '';
  
  # Ensure gh CLI is installed
  environment.systemPackages = with pkgs; [
    gh
    git
  ];
}
