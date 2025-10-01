{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./sequential-thinking.nix
    ./morphllm-fast-apply.nix
    ./context7.nix
    ./playwright.nix
    ./magic.nix
    ./serena.nix
  ];

  options.custom.system.packages.mcp = {
    enableAll = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable all MCP (Model Context Protocol) servers for Claude Code.
        This includes: sequential-thinking, morphllm-fast-apply, context7,
        playwright, magic, and serena.
      '';
    };
  };

  config = mkIf config.custom.system.packages.mcp.enableAll {
    custom.system.packages.mcp = {
      sequential-thinking.enable = mkDefault true;
      morphllm-fast-apply.enable = mkDefault true;
      # context7.enable = mkDefault true;  # Disabled by default - package needs verification
      playwright.enable = mkDefault true;
      magic.enable = mkDefault true;
      # serena.enable = mkDefault true;  # Disabled by default - Python-based, needs testing
    };
  };
}
