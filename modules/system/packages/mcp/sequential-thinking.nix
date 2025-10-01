{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.mcp.sequential-thinking;

  # MCP server for sequential thinking and problem solving
  mcp-sequential-thinking = pkgs.buildNpmPackage rec {
    pname = "modelcontextprotocol-server-sequential-thinking";
    version = "2025.7.1";

    src = pkgs.fetchFromGitHub {
      owner = "modelcontextprotocol";
      repo = "servers";
      rev = "v${version}";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
    };

    # Only build the sequential-thinking server
    sourceRoot = "${src.name}/src/sequentialthinking";

    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash

    # Dependencies for the server
    buildInputs = with pkgs; [
      nodejs
    ];

    # Skip tests for now
    doCheck = false;

    meta = with lib; {
      description = "MCP server for sequential thinking and problem solving";
      homepage = "https://github.com/modelcontextprotocol/servers";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.all;
    };
  };
in
{
  options.custom.system.packages.mcp.sequential-thinking = {
    enable = mkEnableOption "MCP Sequential Thinking Server - Enables step-by-step problem-solving capabilities";

    installGlobally = mkOption {
      type = types.bool;
      default = true;
      description = "Install sequential-thinking MCP server system-wide";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.installGlobally [
      mcp-sequential-thinking
    ];
  };
}
