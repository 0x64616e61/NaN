{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.claude-code;

  # Build Claude Code from npm registry using buildNpmPackage
  claude-code = pkgs.buildNpmPackage rec {
    pname = "claude-code";
    version = "2.0.1";

    # Fetch from npm registry
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha512-2SboYcdJ+dsE2K784dbJ4ohVWlAkLZhU7mZG1lebyG6TvGLXLhjc2qTEfCxSeelCjJHhIh/YkNpe06veB4IgBw==";
    };

    # NPM dependencies hash - will need to be updated via:
    # nix-build -E "with import <nixpkgs> {}; callPackage ./claude-code.nix {}" 2>&1 | grep "got:" | awk '{print $2}'
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    # Node.js 18+ required
    nativeBuildInputs = [ pkgs.nodejs_20 ];

    # Don't run npm audit
    npmFlags = [ "--legacy-peer-deps" ];

    # Disable build scripts that might fail in sandbox
    npmBuildScript = ""; # Claude Code doesn't require build step

    # Create wrapper to ensure proper PATH and environment
    postInstall = ''
      # Ensure the binary is executable
      chmod +x $out/bin/claude || true

      # Create wrapper script with proper environment
      if [ -f "$out/bin/claude" ]; then
        mv $out/bin/claude $out/bin/.claude-wrapped

        cat > $out/bin/claude << 'EOF'
#!/usr/bin/env bash
# Claude Code wrapper with proper environment setup

# Ensure Node.js is in PATH
export PATH="${pkgs.nodejs_20}/bin:$PATH"

# Set npm prefix to avoid permission issues
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# Execute the actual Claude Code binary
exec "$0-wrapped" "$@"
EOF

        # Make wrapper executable
        chmod +x $out/bin/claude

        # Fix the wrapper reference
        sed -i "s|\$0-wrapped|$out/bin/.claude-wrapped|g" $out/bin/claude
      fi
    '';

    meta = with lib; {
      description = "Claude Code - AI coding assistant from Anthropic";
      longDescription = ''
        Claude Code is an agentic coding tool that lives in your terminal,
        understands your codebase, and helps you code faster by executing
        routine tasks, explaining complex code, and handling git workflows
        - all through natural language commands.

        This package provides the official @anthropic-ai/claude-code npm
        package built as a proper Nix derivation with all dependencies
        included for offline installation.

        Features:
        - Full codebase understanding and context
        - Natural language task execution
        - Git workflow automation
        - Code explanation and refactoring
        - Multi-step task planning and execution
        - Supports Sonnet 4.5 and other Claude models
      '';
      homepage = "https://github.com/anthropics/claude-code";
      changelog = "https://github.com/anthropics/claude-code/releases";
      license = licenses.unfree;
      maintainers = [ ];
      platforms = platforms.unix;
      mainProgram = "claude";
    };
  };
in
{
  options.custom.system.packages.claude-code = {
    enable = mkEnableOption "Claude Code - Anthropic's AI coding assistant (npm package build)";

    installGlobally = mkOption {
      type = types.bool;
      default = true;
      description = "Install Claude Code system-wide";
    };

    package = mkOption {
      type = types.package;
      default = claude-code;
      description = "The Claude Code package to install";
    };
  };

  config = mkIf cfg.enable {
    # Install Claude Code package system-wide
    environment.systemPackages = mkIf cfg.installGlobally [
      cfg.package
      pkgs.nodejs_20  # Ensure Node.js runtime is available
    ];

    # Ensure proper environment variables
    environment.variables = {
      # Node.js module path for global packages
      NODE_PATH = "${pkgs.nodejs_20}/lib/node_modules";
    };

    # Add helpful shell aliases
    environment.shellAliases = {
      # Direct invocation
      claude-version = "claude --version";

      # Helpful diagnostics
      claude-check = "which claude && claude --version";

      # Legacy fallback to npx if needed
      claude-npx = "npx @anthropic-ai/claude-code@latest";
    };

    # Session variables for npm
    environment.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
  };
}
