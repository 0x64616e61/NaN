{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hydenix.hm.claude-code;
in
{
  options.hydenix.hm.claude-code = {
    enable = mkEnableOption "claude-code CLI from Anthropic";

    package = mkOption {
      type = types.package;
      default = pkgs.writeScriptBin "claude-code-installer" ''
        #!${pkgs.bash}/bin/bash
        echo "Installing claude-code globally..."
        ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code
      '';
      description = "The claude-code installation script";
    };

    globalInstall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install claude-code globally for CLI access";
    };

    autoUpdate = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically update to the latest version";
    };

    shellAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to create shell aliases for claude-code";
    };
  };

  config = mkIf cfg.enable {
    # Add nodejs and npm to packages
    home.packages = [ pkgs.nodejs cfg.package ];

    # Set up npm global directory
    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };

    # Add npm global bin to PATH
    home.sessionPath = [ "$HOME/.npm-global/bin" ];

    # Create .npm-global directory
    home.file.".npm-global/.keep".text = "";

    # Install claude-code via home activation
    home.activation.installClaudeCode = lib.hm.dag.entryAfter ["writeBoundary"] ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="$HOME/.npm-global/bin:$PATH"
      
      if [ ! -f "$HOME/.npm-global/bin/claude-code" ]; then
        echo "Installing claude-code..."
        $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code
      else
        echo "claude-code already installed"
        ${optionalString cfg.autoUpdate ''
          echo "Updating claude-code..."
          $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm update -g @anthropic-ai/claude-code
        ''}
      fi
    '';

    # Create shell aliases for convenience  
    programs.bash.shellAliases = mkIf (cfg.shellAliases && config.programs.bash.enable) {
      claude-code = "claude";
    };

    programs.zsh.shellAliases = mkIf (cfg.shellAliases && config.programs.zsh.enable) {
      claude-code = "claude";
    };

    programs.fish.shellAliases = mkIf (cfg.shellAliases && config.programs.fish.enable) {
      claude-code = "claude";
    };

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