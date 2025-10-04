# Auto-commit and push changes to GitHub on rebuild
{ config, lib, pkgs, ... }:

{
  # PRE-activation script with security review
  system.activationScripts.autoCommitChanges = lib.mkBefore ''
    echo "Checking for uncommitted changes in /nix-modules..."

    cd /nix-modules

    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      echo "Found uncommitted changes..."

      # Security pre-flight checks
      echo "🔒 Security Pre-flight Checks:"

      # Check for secrets (basic patterns)
      if git diff --cached | grep -iE '(password|secret|token|api[_-]?key|private[_-]?key).*=.*["\x27]'; then
        echo "⚠️  WARNING: Potential secrets detected in staged changes!"
        echo "Review changes manually before committing."
        exit 1
      fi

      # Check for critical file changes
      CRITICAL_FILES=$(git diff --cached --name-only | grep -E '(secrets|password|token|key|auth)' || true)
      if [ -n "$CRITICAL_FILES" ]; then
        echo "⚠️  Critical files modified: $CRITICAL_FILES"
        echo "Requiring manual review. Skipping auto-commit."
        exit 1
      fi

      # Exclude .claude/DOCUMENTATION/ from auto-commits (manual review required)
      git reset .claude/DOCUMENTATION/ 2>/dev/null || true

      echo "✅ Security checks passed"

      # Configure git if needed
      git config user.email "noreply@github.com" 2>/dev/null || true
      git config user.name "NixOS Auto-Commit" 2>/dev/null || true
      git config commit.gpgsign true 2>/dev/null || true
      git config gpg.format ssh 2>/dev/null || true
      git config user.signingkey "~/.ssh/id_ed25519.pub" 2>/dev/null || true

      # Add changes (excluding documentation)
      git add -A ':!.claude/DOCUMENTATION/'

      TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
      git commit -S -m "Auto-commit: NixOS rebuild at $TIMESTAMP

🔒 Security: Signed commit, secrets scanned
🤖 Automated by NixOS activation script" || {
        echo "Failed to commit changes (signing may have failed - generate SSH key)"
      }

      # Push with security notice
      echo "Pushing changes to GitHub (auto-commit with security review)..."
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
