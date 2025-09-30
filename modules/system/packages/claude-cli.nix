{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.claude-cli;

  # Simplified approach using writeShellScriptBin for guaranteed PATH availability
  claude-cli-wrapper = pkgs.writeShellScriptBin "claude" ''
    #!${pkgs.bash}/bin/bash
    export PATH="${pkgs.nodejs}/bin:$PATH"
    exec ${pkgs.nodejs}/bin/npx @anthropic-ai/claude-code@latest "$@"
  '';

  # Custom Claude CLI package derivation for offline installation
  claude-cli = pkgs.stdenv.mkDerivation rec {
    pname = "claude-code";
    version = "latest";

    # Create a minimal derivation that ensures Node.js and npm are available
    src = pkgs.writeText "package.json" ''
      {
        "name": "claude-code-wrapper",
        "version": "1.0.0",
        "description": "NixOS wrapper for Claude Code"
      }
    '';

    nativeBuildInputs = with pkgs; [
      nodejs  # Node.js includes npm
      makeWrapper
    ];

    unpackPhase = "true";
    configurePhase = "true";

    buildPhase = ''
      mkdir -p $out/bin

      # Create a wrapper script that ensures Node.js is in PATH
      cat > $out/bin/claude << 'EOF'
#!/usr/bin/env bash
export PATH="${pkgs.nodejs}/bin:$PATH"
exec ${pkgs.nodejs}/bin/npx @anthropic-ai/claude-code@latest "$@"
EOF

      chmod +x $out/bin/claude
    '';

    installPhase = "true";  # Already done in buildPhase

    meta = with lib; {
      description = "Claude Code - AI coding assistant wrapper for NixOS";
      longDescription = ''
        Claude Code is an agentic coding tool that lives in your terminal,
        understands your codebase, and helps you code faster by executing
        routine tasks, explaining complex code, and handling git workflows
        - all through natural language commands.

        This NixOS package provides a wrapper that ensures the CLI is
        available in your PATH using npx.
      '';
      homepage = "https://github.com/anthropics/claude-code";
      license = licenses.unfree;
      maintainers = [ ];
      platforms = platforms.unix;
    };
  };
in
{
  options.custom.system.packages.claude-cli = {
    enable = mkEnableOption "Claude CLI - Anthropic's AI coding assistant";

    installGlobally = mkOption {
      type = types.bool;
      default = true;
      description = "Install Claude CLI system-wide";
    };

    packageMethod = mkOption {
      type = types.enum [ "npm-direct" "npm-package" ];
      default = "npm-direct";
      description = "Method to build the Claude CLI package";
    };
  };

  config = mkIf cfg.enable {
    # Install Claude CLI and required Node.js tools system-wide
    environment.systemPackages = mkIf cfg.installGlobally [
      (if cfg.packageMethod == "npm-direct" then claude-cli else claude-cli-wrapper)
      pkgs.nodejs  # Ensure latest Node.js is available (includes npm)
    ];

    # Ensure Node.js is available in PATH for all users
    environment.variables = {
      # Ensure Node.js path is available globally
      NODE_PATH = "${pkgs.nodejs}/lib/node_modules";
    };

    # Add helpful aliases for Claude CLI usage
    environment.shellAliases = {
      # Direct npx fallback if needed
      claude-npx = "npx @anthropic-ai/claude-code@latest";
      # Check Claude version (should be 2.0+ for Sonnet 4.5 support)
      claude-version = "claude --version";
      # Updated for Claude Code v2.0+ (September 30, 2025)
      # Note: Sonnet 4.5 requires using /model command in interactive mode
      claude-latest = "npx @anthropic-ai/claude-code@latest";
    };

    # Set NPM configuration for global packages
    environment.sessionVariables = {
      NPM_CONFIG_PREFIX = "${pkgs.nodejs}";
    };
  };
}