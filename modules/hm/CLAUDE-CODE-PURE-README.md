# Claude Code Pure Nix Home Manager Module

Comprehensive Home Manager module for Claude Code CLI with full MCP server integration, permissions management, custom agents, and project-specific configurations.

## Features

- ✅ **Pure Nix Derivation**: Self-contained Claude Code installation
- ✅ **MCP Server Integration**: Full Model Context Protocol support with 6+ default servers
- ✅ **Permissions Management**: Fine-grained control over directory access and capabilities
- ✅ **Custom Agents**: Define specialized AI agents with custom prompts and MCP server access
- ✅ **Project Configuration**: Per-project settings and context management
- ✅ **Shell Integration**: Automatic aliases and functions for bash/zsh/fish
- ✅ **Directory Structure**: Automated `.claude/` directory setup
- ✅ **Configuration Generation**: Dynamic `.claude.json` from Nix attributes

## Installation

### 1. Import the Module

Add to your Home Manager configuration:

```nix
# ~/.config/home-manager/home.nix or modules/hm/default.nix
{
  imports = [
    ./claude-code-pure.nix
  ];
}
```

### 2. Basic Configuration

Minimal setup (uses all defaults):

```nix
programs.claudeCode = {
  enable = true;
};
```

### 3. Rebuild Home Manager

```bash
home-manager switch
```

Or if using NixOS with Home Manager:

```bash
sudo nixos-rebuild switch --flake .#NaN --impure
```

## Configuration Options

### Basic Options

```nix
programs.claudeCode = {
  enable = true;                    # Enable Claude Code
  package = pkgs.claudeCodePkg;     # Custom package (optional)
  defaultModel = "claude-sonnet-4.5";  # Default AI model
  shellIntegration = true;          # Enable shell aliases/functions
  shellAliases = true;              # Create 'cc' alias
};
```

### MCP Server Configuration

#### Using Default Servers

The module includes 6 default MCP servers:

- **sequential-thinking**: Advanced reasoning and chain-of-thought
- **morphllm-fast-apply**: Code transformation and bulk changes
- **context7**: Official documentation and pattern guidance
- **playwright**: Browser automation and testing
- **magic**: UI component generation (21st.dev)
- **serena**: Session management (disabled by default)

```nix
programs.claudeCode = {
  enable = true;

  mcp = {
    enable = true;
    useDefaults = true;  # Include all default servers
  };
};
```

#### Custom MCP Servers

Add your own servers or override defaults:

```nix
programs.claudeCode = {
  enable = true;

  mcp = {
    enable = true;
    useDefaults = true;  # Keep defaults

    servers = {
      # Add custom server
      my-custom-server = {
        command = "python";
        args = [ "-m" "my_mcp_server" ];
        env = {
          DEBUG = "1";
          LOG_LEVEL = "info";
        };
        disabled = false;
      };

      # Override default server
      playwright = {
        command = "${pkgs.nodejs}/bin/npx";
        args = [ "-y" "@modelcontextprotocol/server-playwright" ];
        env = { HEADLESS = "true"; };
        disabled = true;  # Disable this server
      };
    };
  };
};
```

#### Only Custom Servers (No Defaults)

```nix
programs.claudeCode = {
  mcp = {
    enable = true;
    useDefaults = false;  # Don't include defaults

    servers = {
      only-this-server = {
        command = "node";
        args = [ "/path/to/server.js" ];
      };
    };
  };
};
```

### Permissions Configuration

Control what MCP servers can access:

```nix
programs.claudeCode = {
  enable = true;

  permissions = {
    enable = true;

    # Allowed directories
    allowedDirectories = [
      "${config.home.homeDirectory}/projects"
      "${config.home.homeDirectory}/code"
      "/tmp"
    ];

    # Blocked directories (takes precedence)
    blockedDirectories = [
      "${config.home.homeDirectory}/.ssh"
      "${config.home.homeDirectory}/.gnupg"
      "${config.home.homeDirectory}/.password-store"
    ];

    # Network and shell access
    allowNetworkAccess = true;
    allowShellCommands = true;
  };
};
```

### Custom Agents

Define specialized AI agents with custom prompts and capabilities:

```nix
programs.claudeCode = {
  enable = true;

  agents = {
    code-reviewer = {
      name = "Code Reviewer";
      systemPrompt = ''
        You are an expert code reviewer focused on:
        - Security vulnerabilities
        - Performance optimization
        - Best practices and patterns
        - Type safety and error handling
      '';
      enabledMcpServers = [
        "sequential-thinking"
        "context7"
      ];
      maxTokens = 100000;
    };

    documentation-writer = {
      name = "Documentation Writer";
      systemPrompt = ''
        You are a technical documentation specialist.
        Focus on clear, comprehensive documentation with examples.
      '';
      enabledMcpServers = [
        "context7"
        "morphllm-fast-apply"
      ];
      maxTokens = 150000;
    };

    nix-expert = {
      name = "NixOS Expert";
      systemPrompt = ''
        You are a NixOS and Nix language expert.
        Help with package derivations, module development, and system configuration.
      '';
      enabledMcpServers = [
        "sequential-thinking"
        "context7"
        "morphllm-fast-apply"
      ];
      maxTokens = 200000;
    };
  };
};
```

### Project Configuration

Set up project-specific settings:

```nix
programs.claudeCode = {
  enable = true;

  project = {
    enable = true;
    name = "My NixOS Configuration";
    description = ''
      Personal NixOS system configuration with Hyprland desktop.
      Includes custom modules for hardware support and development tools.
    '';
    rootPath = "/home/a/nix-modules";

    includePaths = [
      "modules/"
      "configuration.nix"
      "flake.nix"
      "README.md"
    ];

    excludePaths = [
      ".git"
      "result"
      "*.log"
      ".direnv"
    ];
  };
};
```

### Environment Variables

Add custom environment variables:

```nix
programs.claudeCode = {
  enable = true;

  environmentVariables = {
    CLAUDE_DEBUG = "1";
    CLAUDE_LOG_LEVEL = "debug";
    CLAUDE_CACHE_DIR = "${config.home.homeDirectory}/.cache/claude";
  };
};
```

## Complete Example Configuration

Here's a full example combining all features:

```nix
programs.claudeCode = {
  enable = true;
  defaultModel = "claude-sonnet-4.5";
  shellIntegration = true;
  shellAliases = true;

  # MCP Servers
  mcp = {
    enable = true;
    useDefaults = true;

    servers = {
      # Custom local server
      local-docs = {
        command = "python";
        args = [ "-m" "http.server" "8080" ];
        env = { PYTHONUNBUFFERED = "1"; };
        disabled = false;
      };
    };
  };

  # Permissions
  permissions = {
    enable = true;
    allowedDirectories = [
      "${config.home.homeDirectory}/projects"
      "${config.home.homeDirectory}/nix-modules"
    ];
    blockedDirectories = [
      "${config.home.homeDirectory}/.ssh"
      "${config.home.homeDirectory}/.gnupg"
    ];
    allowNetworkAccess = true;
    allowShellCommands = true;
  };

  # Custom Agents
  agents = {
    nix-expert = {
      name = "NixOS Expert";
      systemPrompt = "You are a NixOS expert specializing in module development.";
      enabledMcpServers = [ "sequential-thinking" "context7" "morphllm-fast-apply" ];
      maxTokens = 200000;
    };

    code-reviewer = {
      name = "Code Reviewer";
      systemPrompt = "You are a security-focused code reviewer.";
      enabledMcpServers = [ "sequential-thinking" "context7" ];
      maxTokens = 100000;
    };
  };

  # Project Settings
  project = {
    enable = true;
    name = "NixOS Configuration";
    description = "Personal NixOS system with custom modules";
    rootPath = "${config.home.homeDirectory}/nix-modules";
    includePaths = [ "modules/" "*.nix" ];
    excludePaths = [ ".git" "result" ];
  };

  # Environment Variables
  environmentVariables = {
    CLAUDE_LOG_LEVEL = "info";
  };
};
```

## Directory Structure

The module creates the following directory structure:

```
~/.claude/
├── config.json          # Generated configuration
├── CLAUDE.md           # Project guidance (if project.enable = true)
├── mcp-cache/          # MCP server cache
├── logs/               # Claude Code logs
└── sessions/           # Session data
```

## Shell Integration

When `shellIntegration = true` and `shellAliases = true`, the following are available:

### Aliases

- `cc` - Short alias for `claude`
- `claude-chat` - Start Claude in chat mode
- `claude-task` - Start Claude in task mode

### Functions

- `claude-here` - Run Claude in current directory with project context

### Example Usage

```bash
# Quick access
cc "explain this code"

# Chat mode
claude-chat

# Task mode with context
claude-task "refactor the authentication module"

# Run in specific directory
claude-here "analyze the project structure"
```

## Utility Commands

The module includes helper scripts:

### Verify Installation

```bash
claude-verify
```

Output:
```
🔍 Verifying Claude Code installation...

✅ Claude Code: 2.0.0
✅ Node.js: v20.11.0
✅ npx: Available

📁 Configuration:
   Config: /home/a/.claude/config.json
   Home: /home/a/.claude

🔧 MCP Servers:
   ✅ sequential-thinking
   ✅ morphllm-fast-apply
   ✅ context7
   ✅ playwright
   ✅ magic
   ⏸️ serena

🤖 Custom Agents: 2
   - NixOS Expert
   - Code Reviewer

✨ Installation verification complete!
```

### Manage MCP Servers

```bash
# List all configured servers
claude-mcp list

# Test a specific server
claude-mcp test sequential-thinking
```

## Generated Configuration File

The module generates `.claude/config.json`:

```json
{
  "version": "1.0",
  "mcpServers": {
    "sequential-thinking": {
      "command": "/nix/store/.../bin/npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "env": {},
      "disabled": false
    },
    "morphllm-fast-apply": {
      "command": "/nix/store/.../bin/npx",
      "args": ["-y", "@modelcontextprotocol/server-morphllm-fast-apply"],
      "env": {},
      "disabled": false
    }
  },
  "permissions": {
    "allowedDirectories": ["/home/a"],
    "blockedDirectories": ["/home/a/.ssh", "/home/a/.gnupg"],
    "allowNetworkAccess": true,
    "allowShellCommands": true
  },
  "agents": {
    "code-reviewer": {
      "systemPrompt": "...",
      "enabledMcpServers": ["sequential-thinking", "context7"],
      "maxTokens": 100000
    }
  },
  "project": {
    "name": "My Project",
    "description": "...",
    "rootPath": "/home/a/projects/myproject",
    "includePaths": ["src/", "lib/"],
    "excludePaths": ["node_modules", ".git"]
  },
  "defaultModel": "claude-sonnet-4.5",
  "shellIntegration": true
}
```

## Migration from Existing Setup

### From claude-code.nix

Replace:

```nix
hydenix.hm.claude-code = {
  enable = true;
  shellAliases = true;
};
```

With:

```nix
programs.claudeCode = {
  enable = true;
  shellAliases = true;
  mcp.enable = true;
  mcp.useDefaults = true;
};
```

### From claude-code-mcp.nix

Replace:

```nix
custom.hm.claudeCode.mcp = {
  enable = true;
  useDefaults = true;
  servers = { ... };
};
```

With:

```nix
programs.claudeCode = {
  enable = true;
  mcp = {
    enable = true;
    useDefaults = true;
    servers = { ... };
  };
};
```

## Troubleshooting

### MCP Server Not Working

1. Check if server is enabled:
   ```bash
   claude-mcp list
   ```

2. Verify Node.js is available:
   ```bash
   node --version
   npx --version
   ```

3. Test server manually:
   ```bash
   npx -y @modelcontextprotocol/server-sequential-thinking
   ```

### Permission Denied

Check your permissions configuration:

```nix
programs.claudeCode.permissions = {
  allowedDirectories = [
    "${config.home.homeDirectory}/your/project"
  ];
};
```

### Config Not Loading

Verify config file exists:

```bash
cat ~/.claude/config.json | jq
```

Check environment variables:

```bash
echo $CLAUDE_CONFIG_PATH
echo $CLAUDE_HOME
```

### Shell Integration Not Working

Ensure your shell configuration is loaded:

```bash
# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc

# Fish
source ~/.config/fish/config.fish
```

## Advanced Usage

### Multiple Environments

Use Home Manager profiles for different setups:

```nix
# Work profile
programs.claudeCode = {
  enable = true;
  project = {
    enable = true;
    name = "Work Project";
    rootPath = "/home/a/work";
  };
  agents.work-agent = { ... };
};

# Personal profile
programs.claudeCode = {
  enable = true;
  project = {
    enable = true;
    name = "Personal Projects";
    rootPath = "/home/a/projects";
  };
  agents.personal-agent = { ... };
};
```

### Custom MCP Server Development

Create your own MCP server:

```nix
programs.claudeCode.mcp.servers.my-server = {
  command = "${pkgs.python3}/bin/python";
  args = [ "${./my-mcp-server.py}" ];
  env = {
    PYTHONPATH = "${pkgs.python3Packages.flask}/lib/python3.11/site-packages";
  };
};
```

### Integration with Other Tools

Combine with Git hooks:

```nix
programs.git.hooks = {
  pre-commit = ''
    claude-task "review changes for security issues"
  '';
};
```

## Performance Tips

1. **Disable Unused MCP Servers**: Set `disabled = true` for servers you don't use
2. **Limit Included Paths**: Only include necessary paths in `project.includePaths`
3. **Use Specific Agents**: Create agents with minimal MCP servers for specific tasks
4. **Cache Management**: Claude automatically manages MCP cache in `~/.claude/mcp-cache`

## Security Considerations

1. **Blocked Directories**: Always block sensitive directories (`.ssh`, `.gnupg`, etc.)
2. **Network Access**: Disable if not needed: `allowNetworkAccess = false`
3. **Shell Commands**: Disable for restricted environments: `allowShellCommands = false`
4. **Review Permissions**: Regularly audit `allowedDirectories`

## Contributing

To contribute to this module:

1. Test changes with `home-manager switch` or `nixos-rebuild switch`
2. Verify with `claude-verify`
3. Check MCP servers with `claude-mcp list`
4. Update documentation as needed

## License

This module is part of the NixOS configuration and follows the same license.

## Support

For issues or questions:

1. Check `claude-verify` output
2. Review logs in `~/.claude/logs/`
3. Verify configuration with `cat ~/.claude/config.json | jq`
4. Test MCP servers with `claude-mcp test <server-name>`

## References

- [Claude Code Documentation](https://github.com/anthropics/claude-code)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
