{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.mcp.serena;

  # Serena MCP server - Python-based semantic code retrieval and editing
  # Note: This is NOT an npm package, it's Python-based using uv
  serena-mcp = pkgs.python3Packages.buildPythonApplication rec {
    pname = "serena-mcp-server";
    version = "unstable-2025-01-01";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "oraios";
      repo = "serena";
      rev = "main"; # Use specific commit or tag when available
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
    };

    # Build dependencies
    nativeBuildInputs = with pkgs.python3Packages; [
      setuptools
      wheel
      hatchling
    ];

    # Runtime dependencies (adjust based on requirements.txt/pyproject.toml)
    propagatedBuildInputs = with pkgs.python3Packages; [
      aiohttp
      pydantic
      click
      rich
      # Add more dependencies as needed from the actual project
    ];

    # Skip tests for now
    doCheck = false;

    # Ensure the MCP server executable is available
    postInstall = ''
      # Create a wrapper script for serena-mcp-server
      mkdir -p $out/bin
      cat > $out/bin/serena-mcp-server <<EOF
#!/usr/bin/env bash
exec ${pkgs.python3}/bin/python -m serena.mcp "\$@"
EOF
      chmod +x $out/bin/serena-mcp-server
    '';

    meta = with lib; {
      description = "Serena MCP Server - Powerful coding agent toolkit with semantic retrieval and editing capabilities";
      homepage = "https://github.com/oraios/serena";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.all;
    };
  };
in
{
  options.custom.system.packages.mcp.serena = {
    enable = mkEnableOption "MCP Serena Server - Semantic code understanding and intelligent editing";

    installGlobally = mkOption {
      type = types.bool;
      default = true;
      description = "Install Serena MCP server system-wide";
    };

    note = mkOption {
      type = types.str;
      default = "Serena is a Python-based MCP server, not npm. Package structure may need adjustment.";
      readOnly = true;
      description = "Important note about this package";
    };
  };

  config = mkIf cfg.enable {
    warnings = [
      "Serena MCP server: This is a Python-based server, not npm. The derivation may need adjustments based on actual project structure."
    ];

    environment.systemPackages = mkIf cfg.installGlobally [
      serena-mcp
    ];

    # Ensure Python is available
    environment.systemPackages = [
      pkgs.python3
      pkgs.uv  # Serena uses uv for package management
    ];
  };
}
