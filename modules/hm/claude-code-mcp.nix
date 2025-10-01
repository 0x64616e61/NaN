{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.claudeCode.mcp;

  # MCP server configuration type
  mcpServerType = types.submodule {
    options = {
      command = mkOption {
        type = types.str;
        description = "Command to start the MCP server";
      };

      args = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Arguments to pass to the MCP server command";
      };

      env = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Environment variables for the MCP server";
      };

      disabled = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this MCP server is disabled";
      };
    };
  };

  # Generate MCP configuration JSON
  mcpConfig = {
    mcpServers = mapAttrs (name: server: {
      inherit (server) command args env disabled;
    }) cfg.servers;
  };

  # Default MCP server configurations
  defaultServers = {
    sequential-thinking = {
      command = "npx";
      args = [ "-y" "@modelcontextprotocol/server-sequential-thinking" ];
      env = {};
      disabled = false;
    };

    morphllm-fast-apply = {
      command = "npx";
      args = [ "-y" "@modelcontextprotocol/server-morphllm-fast-apply" ];
      env = {};
      disabled = false;
    };

    context7 = {
      command = "npx";
      args = [ "-y" "@modelcontextprotocol/server-context7" ];
      env = {};
      disabled = false;
    };

    playwright = {
      command = "npx";
      args = [ "-y" "@modelcontextprotocol/server-playwright" ];
      env = {};
      disabled = false;
    };

    magic = {
      command = "npx";
      args = [ "-y" "@21st-dev/mcp-server-magic" ];
      env = {};
      disabled = false;
    };

    serena = {
      command = "npx";
      args = [ "-y" "@serena/mcp-server" ];
      env = {};
      disabled = true;  # Disabled by default - enable if needed
    };
  };

in
{
  options.custom.hm.claudeCode.mcp = {
    enable = mkEnableOption "MCP (Model Context Protocol) server integration for Claude Code";

    servers = mkOption {
      type = types.attrsOf mcpServerType;
      default = {};
      description = ''
        MCP servers to configure for Claude Code.
        Each server can have custom command, args, env, and disabled state.
      '';
    };

    useDefaults = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to include default MCP server configurations.
        Includes: sequential-thinking, morphllm-fast-apply, context7, playwright, magic.
      '';
    };

    configFile = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/.claude/mcp-config.json";
      description = "Path to the MCP configuration file";
    };
  };

  config = mkIf cfg.enable {
    # Merge default servers with user-defined servers
    custom.hm.claudeCode.mcp.servers = mkMerge [
      (mkIf cfg.useDefaults defaultServers)
      cfg.servers
    ];

    # Write MCP configuration file
    home.file.".claude/mcp-config.json" = {
      text = builtins.toJSON mcpConfig;
    };

    # Ensure required packages are available
    home.packages = with pkgs; [
      nodejs  # Required for npx
    ];

    # Add shell environment for MCP servers
    home.sessionVariables = {
      CLAUDE_MCP_CONFIG = cfg.configFile;
    };
  };
}
