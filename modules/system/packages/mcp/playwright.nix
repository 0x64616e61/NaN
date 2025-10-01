{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.mcp.playwright;

  # Official Playwright MCP server by Microsoft
  mcp-playwright = pkgs.buildNpmPackage rec {
    pname = "playwright-mcp";
    version = "latest";

    src = pkgs.fetchFromGitHub {
      owner = "microsoft";
      repo = "playwright-mcp";
      rev = "main"; # Use specific version tag when available
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
    };

    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash

    # Dependencies for the server
    buildInputs = with pkgs; [
      nodejs
    ];

    # Playwright may need additional system dependencies
    nativeBuildInputs = with pkgs; [
      makeWrapper
    ];

    # Skip tests for now
    doCheck = false;

    # Wrap with playwright system dependencies
    postInstall = ''
      # Ensure playwright browsers are accessible
      wrapProgram $out/bin/playwright-mcp \
        --prefix PATH : ${lib.makeBinPath [ pkgs.playwright-driver.browsers ]}
    '';

    meta = with lib; {
      description = "Official Playwright MCP server by Microsoft - Browser automation capabilities";
      homepage = "https://github.com/microsoft/playwright-mcp";
      license = licenses.apache20;
      maintainers = [ ];
      platforms = platforms.all;
    };
  };
in
{
  options.custom.system.packages.mcp.playwright = {
    enable = mkEnableOption "MCP Playwright Server - Browser automation and testing capabilities";

    installGlobally = mkOption {
      type = types.bool;
      default = true;
      description = "Install playwright MCP server system-wide";
    };

    installBrowsers = mkOption {
      type = types.bool;
      default = true;
      description = "Install Playwright browser binaries (Chromium, Firefox, WebKit)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.installGlobally ([
      mcp-playwright
    ] ++ optionals cfg.installBrowsers [
      pkgs.playwright-driver.browsers
    ]);
  };
}
