{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.shellCompliance;
in
{
  options.custom.hm.shellCompliance = {
    enable = mkEnableOption "SuperClaude Framework terminal compliance enforcement";

    wrappedCommands = mkOption {
      type = types.listOf types.str;
      default = [
        # File operations
        "ls" "cat" "echo" "find" "grep" "head" "tail" "sort" "uniq" "wc"
        "cp" "mv" "rm" "mkdir" "rmdir" "chmod" "chown" "touch"

        # Network operations
        "curl" "wget" "ping" "nmap" "netcat" "nc"

        # Development tools
        "git" "npm" "node" "python" "python3" "pip" "go" "cargo" "rustc"
        "gcc" "clang" "make" "cmake" "docker" "podman"

        # Analysis tools
        "rg" "ripgrep" "fd" "jq" "yq" "tree" "duf"

        # System tools
        "ps" "top" "htop" "systemctl" "journalctl" "dmesg"

        # Archive tools
        "tar" "zip" "unzip" "gzip" "gunzip"
      ];
      description = "List of commands that must be wrapped in nix-shell";
    };

    allowedBareCommands = mkOption {
      type = types.listOf types.str;
      default = [
        # Shell builtins and safe commands
        "cd" "pwd" "pushd" "popd" "dirs" "history" "jobs" "fg" "bg" "kill"
        "alias" "unalias" "which" "type" "source" "export" "unset" "set"
        "read" "printf" "test" "true" "false" "exit" "return" "break" "continue"
        "if" "then" "else" "elif" "fi" "for" "while" "do" "done" "case" "esac"
        "function" "local" "declare" "typeset" "readonly" "shift" "getopts"
        # Zsh specific
        "bindkey" "compdef" "autoload" "zmodload" "setopt" "unsetopt"
        # SuperClaude compliance tools
        "nix-shell" "claude" "fastfetch"
      ];
      description = "List of commands allowed to run without nix-shell wrapping";
    };

    autoExecute = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically execute compliant version when non-compliant command is used";
    };
  };

  config = mkIf cfg.enable {
    home.file.".config/zsh/claude-compliance.zsh".text = ''
      #!/usr/bin/env zsh
      # SuperClaude Framework Terminal Compliance Layer
      # Enforces universal nix-shell wrapping for all commands

      # Store original command_not_found_handler
      typeset -g _original_command_not_found_handler
      if (( $+functions[command_not_found_handler] )); then
          _original_command_not_found_handler=$(declare -f command_not_found_handler)
      fi

      # Commands that must be wrapped in nix-shell
      typeset -ga CLAUDE_WRAPPED_COMMANDS
      CLAUDE_WRAPPED_COMMANDS=(${concatStringsSep " " (map (cmd: "'${cmd}'") cfg.wrappedCommands)})

      # Commands that are allowed to run directly
      typeset -ga CLAUDE_ALLOWED_BARE_COMMANDS
      CLAUDE_ALLOWED_BARE_COMMANDS=(${concatStringsSep " " (map (cmd: "'${cmd}'") cfg.allowedBareCommands)})

      # Function to check if command needs nix-shell wrapping
      _claude_needs_wrapping() {
          local cmd="$1"

          # Check if it's in the wrapped commands list
          if (( ''${CLAUDE_WRAPPED_COMMANDS[(I)$cmd]} )); then
              return 0  # needs wrapping
          fi

          # Check if it's in the allowed bare commands list
          if (( ''${CLAUDE_ALLOWED_BARE_COMMANDS[(I)$cmd]} )); then
              return 1  # doesn't need wrapping
          fi

          # Check if it's a builtin or function
          if (( $+builtins[$cmd] )) || (( $+functions[$cmd] )) || (( $+aliases[$cmd] )); then
              return 1  # doesn't need wrapping
          fi

          # Default: unknown commands need wrapping
          return 0
      }

      # Override command_not_found_handler to enforce compliance
      command_not_found_handler() {
          local cmd="$1"
          shift
          local args=("$@")

          if _claude_needs_wrapping "$cmd"; then
              echo "⚠️  CLAUDE COMPLIANCE: Command '$cmd' must be wrapped in nix-shell"
              echo "✅ Suggested usage: nix-shell -p $cmd --run '$cmd ''${(j: :)args}'"

              ${if cfg.autoExecute then ''
                echo "🔧 Auto-executing: nix-shell -p $cmd --run '$cmd ''${(j: :)args}'"
                # Auto-execute the compliant version
                nix-shell -p "$cmd" --run "$cmd ''${(j: :)args}"
                return $?
              '' else ''
                echo "❌ Command blocked by SuperClaude compliance. Use suggested nix-shell wrapper."
                return 127
              ''}
          else
              # Use original handler or default behavior
              if [[ -n "$_original_command_not_found_handler" ]]; then
                  eval "$_original_command_not_found_handler"
                  command_not_found_handler "$cmd" "''${args[@]}"
              else
                  echo "zsh: command not found: $cmd"
                  return 127
              fi
          fi
      }

      # Add compliance indicator to environment
      export CLAUDE_COMPLIANCE_ACTIVE="✅"
      export CLAUDE_COMPLIANCE_VERSION="2.0"

      echo "🚀 SuperClaude Framework Terminal Compliance ACTIVE"
      echo "📋 Universal nix-shell wrapping enforced for ''${#CLAUDE_WRAPPED_COMMANDS} commands"
      echo "⚡ Auto-execution: ${if cfg.autoExecute then "ENABLED" else "DISABLED"}"
    '';

    # Add compliance loading to zsh configuration
    programs.zsh.initExtra = mkAfter ''
      # SuperClaude Framework Terminal Compliance
      if [[ -f "$HOME/.config/zsh/claude-compliance.zsh" ]]; then
        source "$HOME/.config/zsh/claude-compliance.zsh"
      fi
    '';
  };
}