# Example configuration for Claude Code Pure Nix Home Manager Module
# This file demonstrates various configuration patterns and use cases
#
# Usage:
#   1. Copy relevant sections to your home.nix or modules/hm/default.nix
#   2. Adjust paths and settings to match your environment
#   3. Run: home-manager switch (or nixos-rebuild switch --flake .#NaN --impure)
#   4. Verify: claude-verify

{ config, pkgs, ... }:

{
  # ============================================================================
  # EXAMPLE 1: Minimal Configuration (Recommended Starting Point)
  # ============================================================================
  # Enables Claude Code with all default MCP servers and standard permissions

  programs.claudeCode = {
    enable = true;
    # That's it! Everything else uses sensible defaults
  };


  # ============================================================================
  # EXAMPLE 2: NixOS Development Configuration
  # ============================================================================
  # Optimized for NixOS module development with relevant MCP servers

  programs.claudeCode = {
    enable = true;
    defaultModel = "claude-sonnet-4.5";
    shellIntegration = true;
    shellAliases = true;

    mcp = {
      enable = true;
      useDefaults = true;  # Include all default servers

      servers = {
        # Keep defaults enabled, disable what's not needed
        playwright.disabled = true;  # Not needed for NixOS development
        magic.disabled = true;       # UI components not needed

        # Add custom NixOS documentation server (example)
        # nixos-docs = {
        #   command = "${pkgs.python3}/bin/python";
        #   args = [ "-m" "http.server" "9000" "--directory" "/nix/store/nixos-docs" ];
        #   env = { PYTHONUNBUFFERED = "1"; };
        #   disabled = false;
        # };
      };
    };

    permissions = {
      enable = true;
      allowedDirectories = [
        "${config.home.homeDirectory}/nix-modules"
        "${config.home.homeDirectory}/projects"
        "/tmp"
      ];
      blockedDirectories = [
        "${config.home.homeDirectory}/.ssh"
        "${config.home.homeDirectory}/.gnupg"
        "${config.home.homeDirectory}/.password-store"
      ];
      allowNetworkAccess = true;
      allowShellCommands = true;
    };

    agents = {
      nix-module-developer = {
        name = "NixOS Module Developer";
        systemPrompt = ''
          You are an expert NixOS module developer and Nix language specialist.

          Key responsibilities:
          - Develop Home Manager and NixOS system modules
          - Follow Nix best practices and conventions
          - Use proper module namespacing (custom.system.*, custom.hm.*)
          - Ensure type safety with mkOption types
          - Write comprehensive documentation
          - Test configurations before deployment

          Always consider:
          - Pure functional approach
          - Reproducibility
          - Module aggregation patterns
          - Proper option definitions
          - Error handling and validation
        '';
        enabledMcpServers = [
          "sequential-thinking"
          "context7"
          "morphllm-fast-apply"
        ];
        maxTokens = 200000;
      };

      system-debugger = {
        name = "NixOS System Debugger";
        systemPrompt = ''
          You are a NixOS system debugging expert.

          Focus on:
          - Analyzing journalctl logs
          - Diagnosing systemd service failures
          - Hardware configuration issues
          - Boot problems and kernel panics
          - Network and display issues
          - Permission and path problems

          Use systematic debugging:
          1. Gather error information
          2. Check recent changes
          3. Verify configuration syntax
          4. Test in isolation
          5. Provide clear solutions
        '';
        enabledMcpServers = [
          "sequential-thinking"
        ];
        maxTokens = 150000;
      };
    };

    project = {
      enable = true;
      name = "NixOS Configuration - GPD Pocket 3";
      description = ''
        Personal NixOS system configuration for GPD Pocket 3 handheld PC.

        Features:
        - Hyprland desktop environment via Hydenix framework
        - Custom hardware modules (fingerprint, auto-rotation, gestures)
        - Power management optimizations
        - Modular system and home-manager configuration
        - Auto-commit workflow with GitHub integration
      '';
      rootPath = "${config.home.homeDirectory}/nix-modules";
      includePaths = [
        "modules/"
        "configuration.nix"
        "flake.nix"
        "hardware-config.nix"
        "*.md"
      ];
      excludePaths = [
        ".git"
        "result"
        "*.log"
        ".direnv"
        "droid/"
      ];
    };

    environmentVariables = {
      CLAUDE_LOG_LEVEL = "info";
    };
  };


  # ============================================================================
  # EXAMPLE 3: Web Development Configuration
  # ============================================================================
  # Optimized for web development with UI components and browser testing

  # programs.claudeCode = {
  #   enable = true;
  #   defaultModel = "claude-sonnet-4.5";
  #
  #   mcp = {
  #     enable = true;
  #     useDefaults = true;
  #
  #     servers = {
  #       # Enable UI component generation
  #       magic.disabled = false;
  #
  #       # Enable browser automation
  #       playwright.disabled = false;
  #
  #       # Add custom development server (example)
  #       dev-server = {
  #         command = "${pkgs.nodejs}/bin/npm";
  #         args = [ "run" "dev" ];
  #         env = {
  #           NODE_ENV = "development";
  #           PORT = "3000";
  #         };
  #         disabled = false;
  #       };
  #     };
  #   };
  #
  #   permissions = {
  #     enable = true;
  #     allowedDirectories = [
  #       "${config.home.homeDirectory}/projects/web"
  #       "${config.home.homeDirectory}/projects/react"
  #     ];
  #     allowNetworkAccess = true;  # Required for npm, browser testing
  #     allowShellCommands = true;  # Required for build commands
  #   };
  #
  #   agents = {
  #     react-developer = {
  #       name = "React Developer";
  #       systemPrompt = ''
  #         You are an expert React and TypeScript developer.
  #         Focus on modern React patterns, hooks, and performance.
  #       '';
  #       enabledMcpServers = [
  #         "sequential-thinking"
  #         "context7"
  #         "magic"
  #         "playwright"
  #       ];
  #       maxTokens = 200000;
  #     };
  #
  #     ui-designer = {
  #       name = "UI/UX Designer";
  #       systemPrompt = ''
  #         You are a UI/UX expert specializing in accessible,
  #         responsive design with modern CSS and component libraries.
  #       '';
  #       enabledMcpServers = [
  #         "magic"
  #         "sequential-thinking"
  #       ];
  #       maxTokens = 150000;
  #     };
  #   };
  #
  #   project = {
  #     enable = true;
  #     name = "Web Application";
  #     description = "Modern React web application with TypeScript";
  #     rootPath = "${config.home.homeDirectory}/projects/webapp";
  #     includePaths = [ "src/" "public/" "tests/" ];
  #     excludePaths = [ "node_modules" "dist" "build" ".next" ];
  #   };
  # };


  # ============================================================================
  # EXAMPLE 4: Security-Focused Configuration
  # ============================================================================
  # Restricted environment with minimal permissions

  # programs.claudeCode = {
  #   enable = true;
  #   defaultModel = "claude-sonnet-4.5";
  #
  #   mcp = {
  #     enable = true;
  #     useDefaults = false;  # Only use specific servers
  #
  #     servers = {
  #       sequential-thinking = {
  #         command = "${pkgs.nodejs}/bin/npx";
  #         args = [ "-y" "@modelcontextprotocol/server-sequential-thinking" ];
  #         env = {};
  #         disabled = false;
  #       };
  #
  #       context7 = {
  #         command = "${pkgs.nodejs}/bin/npx";
  #         args = [ "-y" "@modelcontextprotocol/server-context7" ];
  #         env = {};
  #         disabled = false;
  #       };
  #     };
  #   };
  #
  #   permissions = {
  #     enable = true;
  #     allowedDirectories = [
  #       "${config.home.homeDirectory}/projects/safe"  # Only one directory
  #     ];
  #     blockedDirectories = [
  #       "${config.home.homeDirectory}/.ssh"
  #       "${config.home.homeDirectory}/.gnupg"
  #       "${config.home.homeDirectory}/.config"
  #       "${config.home.homeDirectory}/.local"
  #     ];
  #     allowNetworkAccess = false;   # No network access
  #     allowShellCommands = false;   # No shell commands
  #   };
  #
  #   agents = {
  #     code-reviewer = {
  #       name = "Security Code Reviewer";
  #       systemPrompt = ''
  #         You are a security-focused code reviewer.
  #         Analyze code for vulnerabilities, insecure patterns,
  #         and potential exploits. Never execute code, only analyze.
  #       '';
  #       enabledMcpServers = [ "sequential-thinking" ];
  #       maxTokens = 100000;
  #     };
  #   };
  #
  #   shellIntegration = false;  # Disable shell integration
  #   shellAliases = false;      # Disable aliases
  # };


  # ============================================================================
  # EXAMPLE 5: Custom MCP Servers
  # ============================================================================
  # Advanced configuration with custom MCP server implementations

  # programs.claudeCode = {
  #   enable = true;
  #
  #   mcp = {
  #     enable = true;
  #     useDefaults = true;
  #
  #     servers = {
  #       # Python-based custom server
  #       custom-python-server = {
  #         command = "${pkgs.python3}/bin/python";
  #         args = [ "${./mcp-servers/custom-server.py}" ];
  #         env = {
  #           PYTHONPATH = "${pkgs.python3Packages.flask}/lib/python3.11/site-packages";
  #           LOG_LEVEL = "debug";
  #         };
  #         disabled = false;
  #       };
  #
  #       # Node.js local server
  #       local-node-server = {
  #         command = "${pkgs.nodejs}/bin/node";
  #         args = [ "${./mcp-servers/local-server.js}" ];
  #         env = {
  #           NODE_ENV = "production";
  #           PORT = "8080";
  #         };
  #         disabled = false;
  #       };
  #
  #       # Shell script server
  #       shell-utilities = {
  #         command = "${pkgs.bash}/bin/bash";
  #         args = [ "${./mcp-servers/utilities.sh}" ];
  #         env = {
  #           TOOLS_DIR = "${config.home.homeDirectory}/.local/bin";
  #         };
  #         disabled = false;
  #       };
  #     };
  #   };
  # };


  # ============================================================================
  # EXAMPLE 6: Multi-Agent Workflow
  # ============================================================================
  # Complex setup with specialized agents for different tasks

  # programs.claudeCode = {
  #   enable = true;
  #   defaultModel = "claude-sonnet-4.5";
  #
  #   mcp = {
  #     enable = true;
  #     useDefaults = true;
  #   };
  #
  #   agents = {
  #     architect = {
  #       name = "Software Architect";
  #       systemPrompt = ''
  #         You are a senior software architect.
  #         Design system architecture, APIs, and data models.
  #         Focus on scalability, maintainability, and best practices.
  #       '';
  #       enabledMcpServers = [
  #         "sequential-thinking"
  #         "context7"
  #       ];
  #       maxTokens = 200000;
  #     };
  #
  #     implementer = {
  #       name = "Implementation Specialist";
  #       systemPrompt = ''
  #         You are an expert implementation specialist.
  #         Transform designs into working code with tests.
  #         Focus on clean code, error handling, and documentation.
  #       '';
  #       enabledMcpServers = [
  #         "sequential-thinking"
  #         "morphllm-fast-apply"
  #         "context7"
  #       ];
  #       maxTokens = 200000;
  #     };
  #
  #     reviewer = {
  #       name = "Code Reviewer";
  #       systemPrompt = ''
  #         You are a thorough code reviewer.
  #         Review for bugs, security, performance, and style.
  #         Provide constructive feedback with examples.
  #       '';
  #       enabledMcpServers = [
  #         "sequential-thinking"
  #       ];
  #       maxTokens = 150000;
  #     };
  #
  #     tester = {
  #       name = "QA Engineer";
  #       systemPrompt = ''
  #         You are a quality assurance engineer.
  #         Create comprehensive tests, find edge cases,
  #         and ensure code quality.
  #       '';
  #       enabledMcpServers = [
  #         "sequential-thinking"
  #         "playwright"
  #       ];
  #       maxTokens = 150000;
  #     };
  #
  #     documenter = {
  #       name = "Documentation Specialist";
  #       systemPrompt = ''
  #         You are a technical documentation specialist.
  #         Create clear, comprehensive documentation with examples.
  #         Focus on user experience and clarity.
  #       '';
  #       enabledMcpServers = [
  #         "context7"
  #       ];
  #       maxTokens = 150000;
  #     };
  #   };
  #
  #   project = {
  #     enable = true;
  #     name = "Multi-Agent Development Project";
  #     description = ''
  #       Complex software project using specialized AI agents
  #       for architecture, implementation, review, testing, and documentation.
  #     '';
  #     rootPath = "${config.home.homeDirectory}/projects/enterprise";
  #     includePaths = [ "src/" "tests/" "docs/" ];
  #     excludePaths = [ "node_modules" ".git" "dist" ];
  #   };
  # };


  # ============================================================================
  # EXAMPLE 7: Integration with Existing Tools
  # ============================================================================
  # Shows integration with git, direnv, and other development tools

  # programs.claudeCode = {
  #   enable = true;
  #
  #   environmentVariables = {
  #     # Claude-specific
  #     CLAUDE_LOG_LEVEL = "info";
  #     CLAUDE_CACHE_DIR = "${config.home.homeDirectory}/.cache/claude";
  #
  #     # Integration with direnv
  #     CLAUDE_USE_DIRENV = "1";
  #
  #     # Custom paths
  #     CLAUDE_TOOLS_PATH = "${config.home.homeDirectory}/.local/bin";
  #   };
  # };
  #
  # # Git integration
  # programs.git = {
  #   enable = true;
  #   ignores = [
  #     # Claude temporary files
  #     ".claude-session"
  #     ".claude-cache"
  #     ".claude-tmp"
  #   ];
  #
  #   hooks = {
  #     pre-commit = ''
  #       # Optional: Run Claude review before commit
  #       # claude-task "quick security review of staged changes"
  #     '';
  #   };
  # };
  #
  # # Direnv integration
  # programs.direnv = {
  #   enable = true;
  #   nix-direnv.enable = true;
  #
  #   # Add Claude to allowed commands
  #   stdlib = ''
  #     export CLAUDE_PROJECT_ROOT=$(pwd)
  #     export PATH="${config.home.homeDirectory}/.local/bin:$PATH"
  #   '';
  # };
}
