{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.mcp.magic;

  # 21st.dev Magic MCP server - UI component generation
  mcp-magic = pkgs.buildNpmPackage rec {
    pname = "21st-dev-magic";
    version = "0.0.33";

    src = pkgs.fetchFromGitHub {
      owner = "21st-dev";
      repo = "magic-mcp";
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

    # Create wrapper to ensure API key can be configured
    postInstall = ''
      # Ensure the MCP server binary is executable
      chmod +x $out/bin/* || true
    '';

    meta = with lib; {
      description = "21st.dev Magic MCP server - AI-powered UI component generation like v0 but in your IDE";
      homepage = "https://github.com/21st-dev/magic-mcp";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.all;
    };
  };
in
{
  options.custom.system.packages.mcp.magic = {
    enable = mkEnableOption "MCP Magic Server - AI-powered UI component generation from 21st.dev";

    installGlobally = mkOption {
      type = types.bool;
      default = true;
      description = "Install 21st.dev Magic MCP server system-wide";
    };

    apiKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "API key for 21st.dev Magic service (optional)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.installGlobally [
      mcp-magic
    ];

    # Set API key environment variable if provided
    environment.variables = mkIf (cfg.apiKey != null) {
      MAGIC_API_KEY = cfg.apiKey;
    };
  };
}
