{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hydenix.hm.claude-code;

  # Create a proper Nix package for claude-code that fetches latest from npm
  claude-code-pkg = pkgs.stdenv.mkDerivation rec {
    pname = "claude-code";
    version = "latest";

    # We don't need a src since we'll fetch from npm
    dontUnpack = true;

    nativeBuildInputs = with pkgs; [
      nodejs
      makeWrapper
      cacert  # Needed for npm to fetch over HTTPS
    ];

    buildPhase = ''
      # Create a temporary directory for npm
      export HOME=$TMPDIR
      mkdir -p $TMPDIR/npm-cache
      export npm_config_cache=$TMPDIR/npm-cache

      # Create package directory structure
      mkdir -p package
      cd package

      # Create a minimal package.json to fetch claude-code
      cat > package.json <<EOF
      {
        "name": "claude-code-nix",
        "version": "1.0.0",
        "dependencies": {
          "@anthropic-ai/claude-code": "latest"
        }
      }
      EOF

      # Install claude-code (this fetches latest version each rebuild)
      npm install --production --no-save
    '';

    installPhase = ''
      # Create the output directory structure
      mkdir -p $out/lib/node_modules

      # Copy the installed modules
      cp -r node_modules/* $out/lib/node_modules/

      # Create bin directory
      mkdir -p $out/bin

      # Find the claude executable and create wrapper
      if [ -f "$out/lib/node_modules/@anthropic-ai/claude-code/bin/claude" ]; then
        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/claude \
          --add-flags "$out/lib/node_modules/@anthropic-ai/claude-code/bin/claude" \
          --prefix NODE_PATH : "$out/lib/node_modules"
      elif [ -f "$out/lib/node_modules/.bin/claude" ]; then
        # npm might create symlinks in .bin
        makeWrapper $out/lib/node_modules/.bin/claude $out/bin/claude \
          --prefix NODE_PATH : "$out/lib/node_modules"
      else
        # Fallback: create direct node wrapper
        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/claude \
          --add-flags "$out/lib/node_modules/@anthropic-ai/claude-code/dist/index.js" \
          --prefix NODE_PATH : "$out/lib/node_modules"
      fi

      # Create claude-code alias
      ln -s $out/bin/claude $out/bin/claude-code
    '';

    # Mark as impure since it fetches latest from network
    __noChroot = true;

    meta = {
      description = "Claude Code - AI pair programming in your terminal";
      homepage = "https://claude.ai/code";
      platforms = lib.platforms.all;
    };
  };
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
    # Simply add the claude-code package - it's all in the Nix store now!
    home.packages = [ claude-code-pkg ];

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