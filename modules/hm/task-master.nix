{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hydenix.hm.task-master;
in
{
  options.hydenix.hm.task-master = {
    enable = mkEnableOption "task-master AI-powered task management system";

    package = mkOption {
      type = types.package;
      default = pkgs.writeScriptBin "task-master-installer" ''
        #!${pkgs.bash}/bin/bash
        echo "Installing task-master-ai globally..."
        ${pkgs.nodejs}/bin/npm install -g task-master-ai
      '';
      description = "The task-master installation script";
    };

    apiKeys = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        ANTHROPIC_API_KEY = "sk-ant-...";
        OPENAI_API_KEY = "sk-...";
      };
      description = "Optional API keys for AI providers. Not required when using Claude Code subscription.";
    };

    globalInstall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install task-master globally for CLI access";
    };

    mcpConfig = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      example = {
        mcpServers = {
          task-master = {
            command = "task-master";
            args = ["mcp"];
            env = {
              ANTHROPIC_API_KEY = "sk-ant-...";
            };
          };
        };
      };
      description = "MCP (Model Control Protocol) configuration for editor integration";
    };

    initializeProject = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to automatically run 'task-master init' in the user's home directory";
    };
  };

  config = mkIf cfg.enable {
    # Add nodejs and npm to packages
    home.packages = [ pkgs.nodejs cfg.package ];

    # Set up npm global directory (shared with claude-code module)
    home.sessionVariables = cfg.apiKeys // {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };

    # Add npm global bin to PATH
    home.sessionPath = [ "$HOME/.npm-global/bin" ];

    # Create .npm-global directory
    home.file.".npm-global/.keep".text = "";

    # Install task-master-ai via home activation
    home.activation.installTaskMaster = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="$HOME/.npm-global/bin:$PATH"
      
      if [ ! -f "$HOME/.npm-global/bin/task-master" ]; then
        echo "Installing task-master-ai..."
        $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm install -g task-master-ai
      else
        echo "task-master already installed"
      fi
    '';

    # Create MCP configuration file if provided
    home.file.".mcp.json" = mkIf (cfg.mcpConfig != null) {
      text = builtins.toJSON cfg.mcpConfig;
    };

    # Initialize task-master project if requested
    home.activation.initTaskMasterProject = mkIf cfg.initializeProject (
      lib.hm.dag.entryAfter ["installTaskMaster"] ''
        export NPM_CONFIG_PREFIX="$HOME/.npm-global"
        export PATH="$HOME/.npm-global/bin:$PATH"
        
        if [ ! -d "$HOME/.taskmaster" ]; then
          echo "Initializing task-master project..."
          $DRY_RUN_CMD $HOME/.npm-global/bin/task-master init
        fi
      ''
    );

    # Add shell alias for convenience
    programs.bash.shellAliases.tm = mkIf config.programs.bash.enable "task-master";
    programs.zsh.shellAliases.tm = mkIf config.programs.zsh.enable "task-master";
    programs.fish.shellAliases.tm = mkIf config.programs.fish.enable "task-master";

    # Ensure PATH is updated in shell configs
    programs.bash.initExtra = mkIf config.programs.bash.enable ''
      export PATH="$HOME/.npm-global/bin:$PATH"
    '';
    
    programs.zsh.initContent = mkIf config.programs.zsh.enable ''
      export PATH="$HOME/.npm-global/bin:$PATH"
    '';
    
    programs.fish.shellInit = mkIf config.programs.fish.enable ''
      set -gx PATH $HOME/.npm-global/bin $PATH
    '';
  };
}