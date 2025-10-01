# Claude Code Pure Nix - Quick Start Guide

Get Claude Code running with full MCP server integration in under 5 minutes.

## 1. Import the Module

Add to `/home/a/nix-modules/modules/hm/default.nix`:

```nix
{
  imports = [
    ./task-master.nix
    ./claude-code.nix
    ./claude-code-pure.nix  # ← Add this line
    ./applications
    ./audio
    ./desktop
    ./hyprland
    ./waybar
  ];

  # ... rest of your config
}
```

## 2. Enable the Module

Add to the same file (or wherever you configure Home Manager):

```nix
{
  # ... existing config ...

  # Add this configuration
  programs.claudeCode = {
    enable = true;  # That's it for minimal setup!
  };

  # ... rest of your config ...
}
```

## 3. Rebuild Your System

```bash
cd /home/a/nix-modules
sudo nixos-rebuild switch --flake .#NaN --impure
```

## 4. Verify Installation

```bash
claude-verify
```

Expected output:
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

🤖 Custom Agents: 0

✨ Installation verification complete!
```

## 5. Try It Out

```bash
# Short alias
cc "explain what this module does"

# Full command
claude "analyze the claude-code-pure.nix file"

# Task mode
claude-task "create a simple hello world script"

# In current directory
claude-here "what files are in this directory?"
```

## 6. Check MCP Servers

```bash
claude-mcp list
```

## Next Steps

### Recommended: Configure for NixOS Development

Edit `/home/a/nix-modules/modules/hm/default.nix`:

```nix
programs.claudeCode = {
  enable = true;

  # Add NixOS-specific agent
  agents.nix-expert = {
    name = "NixOS Expert";
    systemPrompt = ''
      You are a NixOS module development expert.
      Help with Nix language, module creation, and system configuration.
    '';
    enabledMcpServers = [
      "sequential-thinking"
      "context7"
      "morphllm-fast-apply"
    ];
    maxTokens = 200000;
  };

  # Set project context
  project = {
    enable = true;
    name = "NixOS Configuration";
    description = "Personal NixOS system configuration";
    rootPath = "${config.home.homeDirectory}/nix-modules";
    includePaths = [ "modules/" "*.nix" ];
    excludePaths = [ ".git" "result" ];
  };

  # Restrict permissions for safety
  permissions = {
    allowedDirectories = [
      "${config.home.homeDirectory}/nix-modules"
      "${config.home.homeDirectory}/projects"
    ];
    blockedDirectories = [
      "${config.home.homeDirectory}/.ssh"
      "${config.home.homeDirectory}/.gnupg"
    ];
  };
};
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#NaN --impure
```

### Optional: Disable Old Modules

If you want to fully migrate from the old `claude-code.nix`:

```nix
# Disable old module
hydenix.hm.claude-code.enable = false;

# Use new module
programs.claudeCode.enable = true;
```

## Common Commands

```bash
# Verify installation
claude-verify

# List MCP servers
claude-mcp list

# Test MCP server
claude-mcp test sequential-thinking

# Use Claude
cc "your request here"
claude-task "specific task"
claude-chat  # Interactive chat mode

# Check config
cat ~/.claude/config.json | jq

# View logs
tail -f ~/.claude/logs/latest.log
```

## Troubleshooting

### Command not found: claude

```bash
# Rebuild
cd /home/a/nix-modules
sudo nixos-rebuild switch --flake .#NaN --impure

# Verify PATH
echo $PATH | grep nix/store

# Check installation
which claude
```

### MCP server not working

```bash
# List servers
claude-mcp list

# Check Node.js
node --version
npx --version

# Test server manually
npx -y @modelcontextprotocol/server-sequential-thinking
```

### Config not loading

```bash
# Check config exists
ls -la ~/.claude/

# Verify environment variables
echo $CLAUDE_CONFIG_PATH
echo $CLAUDE_HOME

# Regenerate config
sudo nixos-rebuild switch --flake .#NaN --impure
```

## Documentation

- **Full README**: `/home/a/nix-modules/modules/hm/CLAUDE-CODE-PURE-README.md`
- **Examples**: `/home/a/nix-modules/modules/hm/claude-code-pure-example.nix`
- **Summary**: `/home/a/nix-modules/CLAUDE-CODE-PURE-MODULE-SUMMARY.md`
- **Module Source**: `/home/a/nix-modules/modules/hm/claude-code-pure.nix`

## What You Get

✅ **Pure Nix Derivation**: Fully declarative Claude Code installation
✅ **6 MCP Servers**: Sequential thinking, Morphllm, Context7, Playwright, Magic, Serena
✅ **Permissions System**: Control what Claude can access
✅ **Custom Agents**: Define specialized AI assistants
✅ **Project Config**: Set up project-specific context
✅ **Shell Integration**: Aliases and functions (cc, claude-task, etc.)
✅ **Auto Directory Setup**: `.claude/` structure created automatically
✅ **Utility Scripts**: `claude-verify`, `claude-mcp` for management

## Default Configuration

The minimal `enable = true` gives you:

- ✅ All 6 default MCP servers (serena disabled)
- ✅ Home directory access allowed
- ✅ `.ssh` and `.gnupg` blocked
- ✅ Network access enabled
- ✅ Shell command execution enabled
- ✅ Shell aliases (`cc`, `claude-task`, etc.)
- ✅ Auto-generated `.claude/` directory structure
- ✅ Git ignore patterns for Claude temp files

## Need More Help?

Read the full documentation:
```bash
# Open in your favorite editor
$EDITOR /home/a/nix-modules/modules/hm/CLAUDE-CODE-PURE-README.md

# Or browse examples
$EDITOR /home/a/nix-modules/modules/hm/claude-code-pure-example.nix
```

---

**Ready to code with Claude!** 🚀
