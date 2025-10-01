{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.mcp.context7;

  # Context7 MCP server for documentation and API context
  # Note: Package name needs verification - using placeholder
  mcp-context7 = pkgs.buildNpmPackage rec {
    pname = "context7-mcp-server";
    version = "latest";

    # Placeholder - actual source needs to be determined
    src = pkgs.fetchFromGitHub {
      owner = "context7";
      repo = "mcp-server";
      rev = "main";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
    };

    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash

    # Dependencies for the server
    buildInputs = with pkgs; [
      nodejs
    ];

    # Skip tests for now
    doCheck = false;

    meta = with lib; {
      description = "MCP server for documentation and API context retrieval";
      homepage = "https://github.com/context7/mcp-server";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.all;
    };
  };
in
{
  options.custom.system.packages.mcp.context7 = {
    enable = mkEnableOption "MCP Context7 Server - Documentation and API context capabilities";

    installGlobally = mkOption {
      type = types.bool;
      default = true;
      description = "Install context7 MCP server system-wide";
    };

    note = mkOption {
      type = types.str;
      default = "Package source needs verification - @modelcontextprotocol/server-context7 does not exist in npm registry";
      readOnly = true;
      description = "Important note about this package";
    };
  };

  config = mkIf cfg.enable {
    # Disabled by default until proper package source is identified
    warnings = [
      "context7 MCP server: Package source needs verification. @modelcontextprotocol/server-context7 does not exist in npm registry."
    ];

    environment.systemPackages = mkIf cfg.installGlobally [
      # mcp-context7  # Commented out until proper source is verified
    ];
  };
}
