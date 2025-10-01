{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.claudeCode;

  # Pure Nix Claude Code derivation
  claudeCodePkg = pkgs.stdenv.mkDerivation rec {
    pname = "claude-code";
    version = "2.0.0";

    src = pkgs.writeText "package.json" ''
      {
        "name": "claude-code-nix",
        "version": "${version}",
        "description": "Pure Nix derivation for Claude Code CLI"
      }
    '';

    nativeBuildInputs = with pkgs; [
      nodejs
      makeWrapper
    ];

    unpackPhase = "true";
    configurePhase = "true";

    buildPhase = ''
      mkdir -p $out/bin

      # Create wrapper script with proper environment
      cat > $out/bin/claude << 'EOF'
#!/usr/bin/env bash
export PATH="${pkgs.nodejs}/bin:$PATH"
export NODE_PATH="${pkgs.nodejs}/lib/node_modules"
exec ${pkgs.nodejs}/bin/npx @anthropic-ai/claude-code@latest "$@"
EOF

      chmod +x $out/bin/claude
    '';

    installPhase = "true";

    meta = with lib; {
      description = "Claude Code - AI coding assistant CLI";
      homepage = "https://github.com/anthropics/claude-code";
      license = licenses.unfree;
      platforms = platforms.unix;
      maintainers = [ ];
    };
  };

  # MCP Server type definition
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

  # Permission configuration type
  permissionType = types.submodule {
    options = {
      allowedDirectories = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of directories that MCP servers can access";
      };

      blockedDirectories = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of directories that MCP servers cannot access";
      };

      allowNetworkAccess = mkOption {
        type = types.bool;
        default = true;
        description = "Whether MCP servers can access the network";
      };

      allowShellCommands = mkOption {
        type = types.bool;
        default = true;
        description = "Whether MCP servers can execute shell commands";
      };
    };
  };

  # Agent configuration type
  agentType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Name of the agent";
      };

      systemPrompt = mkOption {
        type = types.str;
        default = "";
        description = "Custom system prompt for this agent";
      };

      enabledMcpServers = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of MCP server names to enable for this agent";
      };

      maxTokens = mkOption {
        type = types.int;
        default = 200000;
        description = "Maximum tokens for this agent";
      };
    };
  };

  # Default MCP server configurations
  defaultMcpServers = {
    sequential-thinking = {
      command = "${pkgs.nodejs}/bin/npx";
      args = [ "-y" "@modelcontextprotocol/server-sequential-thinking" ];
      env = {};
      disabled = false;
    };

    morphllm-fast-apply = {
      command = "${pkgs.nodejs}/bin/npx";
      args = [ "-y" "@modelcontextprotocol/server-morphllm-fast-apply" ];
      env = {};
      disabled = false;
    };

    context7 = {
      command = "${pkgs.nodejs}/bin/npx";
      args = [ "-y" "@modelcontextprotocol/server-context7" ];
      env = {};
      disabled = false;
    };

    playwright = {
      command = "${pkgs.nodejs}/bin/npx";
      args = [ "-y" "@modelcontextprotocol/server-playwright" ];
      env = {};
      disabled = false;
    };

    magic = {
      command = "${pkgs.nodejs}/bin/npx";
      args = [ "-y" "@21st-dev/mcp-server-magic" ];
      env = {};
      disabled = false;
    };

    serena = {
      command = "${pkgs.nodejs}/bin/npx";
      args = [ "-y" "@serena/mcp-server" ];
      env = {};
      disabled = true;
    };
  };

  # Merge user MCP servers with defaults
  mergedMcpServers = if cfg.mcp.useDefaults
    then defaultMcpServers // cfg.mcp.servers
    else cfg.mcp.servers;

  # Generate .claude.json configuration
  claudeConfig = {
    version = "1.0";

    # MCP servers configuration
    mcpServers = mapAttrs (name: server: {
      inherit (server) command args env disabled;
    }) (filterAttrs (n: v: !v.disabled) mergedMcpServers);

    # Permissions configuration
    permissions = optionalAttrs cfg.permissions.enable {
      allowedDirectories = cfg.permissions.allowedDirectories;
      blockedDirectories = cfg.permissions.blockedDirectories;
      allowNetworkAccess = cfg.permissions.allowNetworkAccess;
      allowShellCommands = cfg.permissions.allowShellCommands;
    };

    # Agents configuration
    agents = optionalAttrs (cfg.agents != {}) (
      mapAttrs (name: agent: {
        inherit (agent) systemPrompt enabledMcpServers maxTokens;
      }) cfg.agents
    );

    # Project-specific settings
    project = optionalAttrs cfg.project.enable {
      name = cfg.project.name;
      description = cfg.project.description;
      rootPath = cfg.project.rootPath;
      includePaths = cfg.project.includePaths;
      excludePaths = cfg.project.excludePaths;
    };

    # Model preferences
    defaultModel = cfg.defaultModel;

    # Shell integration
    shellIntegration = cfg.shellIntegration;
  };

  # Generate shell integration scripts
  shellInitBash = ''
    # Claude Code shell integration
    if [ -n "$BASH_VERSION" ]; then
      alias cc='claude'
      alias claude-chat='claude --mode chat'
      alias claude-task='claude --mode task'

      # Quick project context
      claude-here() {
        cd "$(pwd)" && claude "$@"
      }
    fi
  '';

  shellInitZsh = ''
    # Claude Code shell integration
    if [ -n "$ZSH_VERSION" ]; then
      alias cc='claude'
      alias claude-chat='claude --mode chat'
      alias claude-task='claude --mode task'

      # Quick project context
      claude-here() {
        cd "$(pwd)" && claude "$@"
      }
    fi
  '';

  shellInitFish = ''
    # Claude Code shell integration
    if status is-interactive
      alias cc='claude'
      alias claude-chat='claude --mode chat'
      alias claude-task='claude --mode task'

      # Quick project context
      function claude-here
        cd (pwd) && claude $argv
      end
    end
  '';

in
{
  options.programs.claudeCode = {
    enable = mkEnableOption "Claude Code - AI coding assistant";

    package = mkOption {
      type = types.package;
      default = claudeCodePkg;
      description = "The Claude Code package to use";
    };

    # MCP Server Configuration
    mcp = {
      enable = mkEnableOption "MCP (Model Context Protocol) server integration" // {
        default = true;
      };

      servers = mkOption {
        type = types.attrsOf mcpServerType;
        default = {};
        description = ''
          Custom MCP servers to configure for Claude Code.
          These will be merged with or replace default servers based on useDefaults.
        '';
        example = literalExpression ''
          {
            custom-server = {
              command = "python";
              args = [ "-m" "my_mcp_server" ];
              env = { "MCP_DEBUG" = "1"; };
              disabled = false;
            };
          }
        '';
      };

      useDefaults = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to include default MCP server configurations.
          Default servers: sequential-thinking, morphllm-fast-apply,
          context7, playwright, magic.
        '';
      };
    };

    # Permissions Configuration
    permissions = {
      enable = mkEnableOption "Permissions management for MCP servers" // {
        default = true;
      };

      allowedDirectories = mkOption {
        type = types.listOf types.str;
        default = [ "${config.home.homeDirectory}" ];
        description = "Directories that MCP servers can access";
      };

      blockedDirectories = mkOption {
        type = types.listOf types.str;
        default = [
          "${config.home.homeDirectory}/.ssh"
          "${config.home.homeDirectory}/.gnupg"
        ];
        description = "Directories that MCP servers cannot access";
      };

      allowNetworkAccess = mkOption {
        type = types.bool;
        default = true;
        description = "Whether MCP servers can access the network";
      };

      allowShellCommands = mkOption {
        type = types.bool;
        default = true;
        description = "Whether MCP servers can execute shell commands";
      };
    };

    # Agent Configuration
    agents = mkOption {
      type = types.attrsOf agentType;
      default = {};
      description = ''
        Custom agents with specific configurations.
        Agents can have different system prompts and enabled MCP servers.
      '';
      example = literalExpression ''
        {
          code-reviewer = {
            name = "Code Reviewer";
            systemPrompt = "You are an expert code reviewer focused on security and performance.";
            enabledMcpServers = [ "sequential-thinking" "context7" ];
            maxTokens = 100000;
          };
        }
      '';
    };

    # Project Configuration
    project = {
      enable = mkEnableOption "Project-specific settings";

      name = mkOption {
        type = types.str;
        default = "";
        description = "Project name";
      };

      description = mkOption {
        type = types.str;
        default = "";
        description = "Project description";
      };

      rootPath = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}";
        description = "Project root path";
      };

      includePaths = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Paths to include in project context";
      };

      excludePaths = mkOption {
        type = types.listOf types.str;
        default = [
          "node_modules"
          ".git"
          "dist"
          "build"
          ".cache"
        ];
        description = "Paths to exclude from project context";
      };
    };

    # Model Configuration
    defaultModel = mkOption {
      type = types.str;
      default = "claude-sonnet-4.5";
      description = "Default Claude model to use";
    };

    # Shell Integration
    shellIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell integration (aliases and functions)";
    };

    shellAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Create shell aliases for Claude Code";
    };

    # Environment Variables
    environmentVariables = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional environment variables for Claude Code";
      example = literalExpression ''
        {
          CLAUDE_DEBUG = "1";
          CLAUDE_LOG_LEVEL = "info";
        }
      '';
    };

    # Configuration File
    configFile = mkOption {
      type = types.path;
      default = "${config.home.homeDirectory}/.claude/config.json";
      description = "Path to Claude Code configuration file";
    };
  };

  config = mkIf cfg.enable {
    # Install Claude Code package
    home.packages = [
      cfg.package
      pkgs.nodejs  # Required for npx and MCP servers
    ];

    # Create .claude directory structure
    home.file.".claude/.keep".text = "";

    # Generate .claude.json configuration
    home.file.".claude/config.json" = {
      text = builtins.toJSON claudeConfig;
    };

    # Create CLAUDE.md guidance file
    home.file.".claude/CLAUDE.md" = mkIf cfg.project.enable {
      text = ''
        # ${cfg.project.name}

        ${cfg.project.description}

        ## Project Structure

        Root Path: ${cfg.project.rootPath}

        ### Included Paths
        ${concatMapStringsSep "\n" (p: "- ${p}") cfg.project.includePaths}

        ### Excluded Paths
        ${concatMapStringsSep "\n" (p: "- ${p}") cfg.project.excludePaths}

        ## Available MCP Servers

        ${concatMapStringsSep "\n" (name: "- **${name}**: ${
          if mergedMcpServers.${name}.disabled then "(disabled)" else "(enabled)"
        }") (attrNames mergedMcpServers)}

        ## Custom Agents

        ${concatMapStringsSep "\n\n" (name: let
          agent = cfg.agents.${name};
        in ''
          ### ${agent.name}
          ${agent.systemPrompt}

          Enabled MCP Servers: ${concatStringsSep ", " agent.enabledMcpServers}
        '') (attrNames cfg.agents)}

        ## Configuration

        - Default Model: ${cfg.defaultModel}
        - Shell Integration: ${if cfg.shellIntegration then "Enabled" else "Disabled"}
        - Config File: ${cfg.configFile}
      '';
    };

    # Shell integration
    programs.bash.initExtra = mkIf (cfg.shellIntegration && cfg.shellAliases) shellInitBash;
    programs.zsh.initExtra = mkIf (cfg.shellIntegration && cfg.shellAliases) shellInitZsh;
    programs.fish.interactiveShellInit = mkIf (cfg.shellIntegration && cfg.shellAliases) shellInitFish;

    # Environment variables
    home.sessionVariables = {
      CLAUDE_CONFIG_PATH = cfg.configFile;
      CLAUDE_HOME = "${config.home.homeDirectory}/.claude";
      NODE_PATH = "${pkgs.nodejs}/lib/node_modules";
    } // cfg.environmentVariables;

    # XDG configuration
    xdg.configFile."claude/config.json" = {
      source = config.home.file.".claude/config.json".source;
    };

    # Git ignore for Claude Code temporary files
    programs.git.ignores = mkIf (config.programs.git.enable) [
      ".claude-session"
      ".claude-cache"
      ".claude-tmp"
    ];

    # Create MCP server cache directory
    home.file.".claude/mcp-cache/.keep".text = "";

    # Create logs directory
    home.file.".claude/logs/.keep".text = "";

    # Create sessions directory
    home.file.".claude/sessions/.keep".text = "";

    # Installation verification script
    home.packages = [
      (pkgs.writeScriptBin "claude-verify" ''
        #!${pkgs.bash}/bin/bash

        echo "🔍 Verifying Claude Code installation..."
        echo ""

        # Check Claude Code
        if command -v claude &> /dev/null; then
          echo "✅ Claude Code: $(claude --version 2>&1 | head -1)"
        else
          echo "❌ Claude Code: Not found"
        fi

        # Check Node.js
        if command -v node &> /dev/null; then
          echo "✅ Node.js: $(node --version)"
        else
          echo "❌ Node.js: Not found"
        fi

        # Check npx
        if command -v npx &> /dev/null; then
          echo "✅ npx: Available"
        else
          echo "❌ npx: Not found"
        fi

        echo ""
        echo "📁 Configuration:"
        echo "   Config: ${cfg.configFile}"
        echo "   Home: $CLAUDE_HOME"

        echo ""
        echo "🔧 MCP Servers:"
        ${concatMapStringsSep "\n" (name:
          "echo '   ${if mergedMcpServers.${name}.disabled then "⏸️" else "✅"} ${name}'"
        ) (attrNames mergedMcpServers)}

        echo ""
        echo "🤖 Custom Agents: ${toString (length (attrNames cfg.agents))}"
        ${concatMapStringsSep "\n" (name:
          "echo '   - ${cfg.agents.${name}.name}'"
        ) (attrNames cfg.agents)}

        echo ""
        echo "✨ Installation verification complete!"
      '')
    ];

    # MCP server management script
    home.packages = [
      (pkgs.writeScriptBin "claude-mcp" ''
        #!${pkgs.bash}/bin/bash

        case "$1" in
          list)
            echo "📋 Available MCP Servers:"
            echo ""
            ${concatMapStringsSep "\n" (name: let
              server = mergedMcpServers.${name};
              status = if server.disabled then "⏸️  DISABLED" else "✅ ENABLED ";
            in ''
              echo "  ${status} ${name}"
              echo "     Command: ${server.command} ${concatStringsSep " " server.args}"
            '') (attrNames mergedMcpServers)}
            ;;
          test)
            if [ -z "$2" ]; then
              echo "Usage: claude-mcp test <server-name>"
              exit 1
            fi
            echo "🧪 Testing MCP server: $2"
            # Add test logic here
            ;;
          *)
            echo "Usage: claude-mcp {list|test}"
            echo ""
            echo "Commands:"
            echo "  list         List all configured MCP servers"
            echo "  test <name>  Test a specific MCP server"
            ;;
        esac
      '')
    ];
  };
}
