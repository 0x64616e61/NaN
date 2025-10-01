{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.mcp.morphllm-fast-apply;

  # MCP server with Morph AI-powered file editing using fast apply model
  mcp-morphllm-fast-apply = pkgs.buildNpmPackage rec {
    pname = "morph-llm-morph-fast-apply";
    version = "0.6.9";

    src = pkgs.fetchFromGitHub {
      owner = "morph-llm";
      repo = "morph-fast-apply";
      rev = "v${version}";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
    };

    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash

    # Dependencies for the server
    buildInputs = with pkgs; [
      nodejs
    ];

    # Skip tests for now
    doCheck = false;

    # Create wrapper script to ensure proper execution
    postInstall = ''
      # Ensure the MCP server binary is executable
      chmod +x $out/bin/* || true
    '';

    meta = with lib; {
      description = "MCP server with Morph AI-powered file editing using fast apply model";
      homepage = "https://github.com/morph-llm/morph-fast-apply";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.all;
    };
  };
in
{
  options.custom.system.packages.mcp.morphllm-fast-apply = {
    enable = mkEnableOption "MCP Morphllm Fast Apply Server - AI-powered file editing capabilities";

    installGlobally = mkOption {
      type = types.bool;
      default = true;
      description = "Install morphllm-fast-apply MCP server system-wide";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.installGlobally [
      mcp-morphllm-fast-apply
    ];
  };
}
