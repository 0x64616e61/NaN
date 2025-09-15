{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hydenix.hm.claude-code;

  # Create a wrapper that manages claude-code installation in user's home
  claude-code-pkg = pkgs.writeScriptBin "claude" ''
    #!${pkgs.bash}/bin/bash

    CLAUDE_DIR="$HOME/.local/share/claude-code"
    CLAUDE_BIN="$CLAUDE_DIR/node_modules/.bin/claude"

    # Check if claude-code is installed
    if [ ! -f "$CLAUDE_BIN" ]; then
      echo "Claude Code not found. Installing..."
      mkdir -p "$CLAUDE_DIR"
      cd "$CLAUDE_DIR"

      # Create package.json for local installation
      cat > package.json <<EOF
    {
      "name": "claude-code-local",
      "version": "1.0.0",
      "dependencies": {
        "@anthropic-ai/claude-code": "latest"
      }
    }
    EOF

      # Install claude-code
      ${pkgs.nodejs}/bin/npm install --production

      if [ -f "$CLAUDE_BIN" ]; then
        echo "Claude Code installed successfully!"
      else
        echo "Failed to install Claude Code"
        exit 1
      fi
    fi

    # Run claude-code with proper NODE_PATH
    export NODE_PATH="$CLAUDE_DIR/node_modules"
    exec ${pkgs.nodejs}/bin/node "$CLAUDE_BIN" "$@"
  '';
in
{
  options.hydenix.hm.claude-code = {
    enable = mkEnableOption "claude-code CLI from Anthropic";

    shellAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to create shell alias 'cc' for claude command";
    };
  };

  config = mkIf cfg.enable {
    # Add the claude wrapper and nodejs
    home.packages = [
      claude-code-pkg
      pkgs.nodejs  # Needed for npm
      (pkgs.writeScriptBin "claude-code" ''
        #!${pkgs.bash}/bin/bash
        exec ${claude-code-pkg}/bin/claude "$@"
      '')
    ];

    # Create shell aliases for convenience if requested
    programs.bash.shellAliases = mkIf (cfg.shellAliases && config.programs.bash.enable) {
      cc = "claude";
    };

    programs.zsh.shellAliases = mkIf (cfg.shellAliases && config.programs.zsh.enable) {
      cc = "claude";
    };

    programs.fish.shellAliases = mkIf (cfg.shellAliases && config.programs.fish.enable) {
      cc = "claude";
    };
  };
}