# Auto-commit and push changes to GitHub on rebuild
{ config, lib, pkgs, ... }:

{
  # Create a system activation script that runs before rebuild
  system.activationScripts.autoCommitChanges = lib.mkAfter ''
    echo "Checking for uncommitted changes in /nix-modules..."
    
    # Check if gh CLI is available
    if ! command -v gh &> /dev/null; then
      echo "GitHub CLI (gh) not found, skipping auto-commit"
      exit 0
    fi
    
    # Change to the nix-modules directory
    cd /nix-modules
    
    # Check if there are any changes
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      echo "Found uncommitted changes, committing..."
      
      # Configure git if needed
      git config user.email "noreply@github.com" 2>/dev/null || true
      git config user.name "NixOS Auto-Commit" 2>/dev/null || true
      
      # Add all changes
      git add -A
      
      # Create commit message with timestamp
      TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
      git commit -m "Auto-commit: NixOS rebuild at $TIMESTAMP" || {
        echo "Failed to commit changes"
        exit 0
      }
      
      # Try to push using gh CLI (which handles authentication)
      echo "Pushing changes to GitHub..."
      gh repo sync --branch main || {
        echo "Failed to push changes (may need authentication)"
        echo "Run 'gh auth login' to authenticate"
      }
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
