# MCP Server Nix Derivations for Claude Code

Pure Nix derivations for all Model Context Protocol (MCP) servers used by Claude Code.

## Overview

This directory contains individual Nix derivations for each MCP server, allowing them to be installed declaratively through NixOS configuration rather than using `npx -y` at runtime.

## Available MCP Servers

### 1. Sequential Thinking (`sequential-thinking.nix`)
- **Package**: `@modelcontextprotocol/server-sequential-thinking`
- **Version**: 2025.7.1
- **Status**: ✅ Verified - npm package exists
- **Description**: MCP server for sequential thinking and problem solving
- **Repository**: https://github.com/modelcontextprotocol/servers
- **License**: MIT

### 2. Morphllm Fast Apply (`morphllm-fast-apply.nix`)
- **Package**: `@morph-llm/morph-fast-apply` (NOT `@modelcontextprotocol/server-morphllm-fast-apply`)
- **Version**: 0.6.9
- **Status**: ⚠️ Package name corrected from original
- **Description**: MCP server with Morph AI-powered file editing using fast apply model
- **Repository**: https://github.com/morph-llm/morph-fast-apply
- **License**: MIT

### 3. Context7 (`context7.nix`)
- **Package**: Unknown - `@modelcontextprotocol/server-context7` does not exist
- **Version**: N/A
- **Status**: ❌ Needs verification - package not found in npm registry
- **Description**: MCP server for documentation and API context retrieval (assumed)
- **Repository**: Unknown
- **License**: Unknown
- **Note**: Disabled by default until proper package source is identified

### 4. Playwright (`playwright.nix`)
- **Package**: `@playwright/mcp` (NOT `@modelcontextprotocol/server-playwright`)
- **Version**: Latest
- **Status**: ✅ Verified - official Microsoft package
- **Description**: Official Playwright MCP server by Microsoft for browser automation
- **Repository**: https://github.com/microsoft/playwright-mcp
- **License**: Apache 2.0
- **Dependencies**: Requires Playwright browser binaries (Chromium, Firefox, WebKit)

### 5. Magic (`magic.nix`)
- **Package**: `@21st-dev/magic` (NOT `@21st-dev/mcp-server-magic`)
- **Version**: 0.0.33
- **Status**: ✅ Verified - npm package exists
- **Description**: 21st.dev Magic MCP server - AI-powered UI component generation
- **Repository**: https://github.com/21st-dev/magic-mcp
- **License**: MIT
- **Note**: May require API key from 21st.dev

### 6. Serena (`serena.nix`)
- **Package**: Python-based project (NOT an npm package)
- **Version**: Unstable
- **Status**: ⚠️ Python-based, not npm - different build approach
- **Description**: Powerful coding agent toolkit with semantic retrieval and editing capabilities
- **Repository**: https://github.com/oraios/serena
- **License**: MIT
- **Note**: Uses Python buildPythonApplication instead of buildNpmPackage

## Usage

### Enable Individual MCP Servers

In your NixOS configuration:

```nix
custom.system.packages.mcp = {
  sequential-thinking.enable = true;
  morphllm-fast-apply.enable = true;
  playwright.enable = true;
  magic.enable = true;
  # context7.enable = true;  # Disabled - needs verification
  # serena.enable = true;     # Disabled - needs testing
};
```

### Enable All MCP Servers

```nix
custom.system.packages.mcp.enableAll = true;
```

### Configuration Options

Each MCP server supports:

- `enable`: Enable/disable the server
- `installGlobally`: Install system-wide (default: true)

Additional server-specific options:

#### Playwright
```nix
custom.system.packages.mcp.playwright = {
  enable = true;
  installBrowsers = true;  # Install browser binaries
};
```

#### Magic
```nix
custom.system.packages.mcp.magic = {
  enable = true;
  apiKey = "your-api-key";  # Optional API key
};
```

## Integration with Claude Code

After enabling MCP servers, update your Claude Code configuration to use the Nix-installed packages instead of `npx`:

### Before (using npx)
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

### After (using Nix derivations)
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "modelcontextprotocol-server-sequential-thinking",
      "args": []
    }
  }
}
```

## Building and Testing

### Get Package Hashes

The derivations currently have placeholder hashes (`sha256-AAAA...`). To get the correct hashes:

```bash
# For GitHub sources
nix-prefetch-github <owner> <repo>

# For npm packages
nix-prefetch-url --unpack https://registry.npmjs.org/@scope/package/-/package-version.tgz

# For npm dependencies hash
# Set npmDepsHash to empty string "", try to build, Nix will tell you the correct hash
```

### Build Individual Server

```bash
nix-build -E 'with import <nixpkgs> {}; callPackage ./sequential-thinking.nix {}'
```

### Test Configuration

```bash
sudo nixos-rebuild test --flake .#NaN --impure
```

## Known Issues and TODOs

### High Priority
1. **Context7**: Package `@modelcontextprotocol/server-context7` does not exist in npm registry
   - Need to identify correct package name or source
   - Currently disabled by default with warning

2. **Hash Placeholders**: All derivations have placeholder hashes that need to be replaced
   - Use `nix-prefetch-github` or `nix-prefetch-url` to get correct hashes
   - Build will fail until hashes are updated

3. **Serena**: Python-based package needs proper dependency specification
   - Currently uses placeholder dependencies
   - Need to parse requirements.txt or pyproject.toml from actual repo

### Medium Priority
4. **Morphllm Package Name**: Corrected from `@modelcontextprotocol/server-morphllm-fast-apply` to `@morph-llm/morph-fast-apply`
   - Verify this is the correct package

5. **Magic API Key**: Consider secure secret management for API key
   - Current implementation uses plain text environment variable
   - Should integrate with KeePassXC or sops-nix for secrets

6. **Playwright Browsers**: Browser binary wrapping needs testing
   - May need additional system dependencies
   - Path wrapping might need adjustment

### Low Priority
7. **Version Pinning**: Some packages use "latest" or "main" instead of specific versions
   - Should pin to specific versions for reproducibility

8. **Testing**: No automated tests for the derivations
   - Should add checks to verify MCP servers start correctly

9. **Documentation**: Add examples of actual Claude Code config integration
   - Show complete before/after configurations

## Development Workflow

### Adding a New MCP Server

1. Create new `.nix` file in this directory
2. Use `buildNpmPackage` for npm packages, `buildPythonApplication` for Python
3. Add import to `default.nix`
4. Define options under `custom.system.packages.mcp.<servername>`
5. Test with `nixos-rebuild test`
6. Update this README

### Updating Versions

1. Change `version` in the derivation
2. Update `rev` for GitHub sources
3. Clear hash (set to empty string "")
4. Run build - Nix will provide correct hash
5. Update hash in derivation

## Architecture Notes

### Why Not Use npx?

The current Claude Code MCP configuration uses `npx -y` to run MCP servers, which:
- Downloads packages on every invocation
- Relies on npm registry availability
- Doesn't leverage Nix's reproducibility
- Can't be easily versioned or pinned

These pure Nix derivations provide:
- Declarative, reproducible builds
- Version pinning and rollback capability
- Offline availability (after initial build)
- Integration with NixOS module system
- Binary caching through Nix store

### Build Process

For npm packages:
```nix
buildNpmPackage {
  pname = "package-name";
  version = "1.0.0";
  src = fetchFromGitHub { ... };
  npmDepsHash = "sha256-...";  # Hash of node_modules
}
```

For Python packages:
```nix
buildPythonApplication {
  pname = "package-name";
  version = "1.0.0";
  format = "pyproject";
  src = fetchFromGitHub { ... };
  propagatedBuildInputs = [ ... ];
}
```

## Contributing

When updating these derivations:

1. Always verify package existence in npm/PyPI registry
2. Use specific version tags, not "latest" or "main"
3. Include proper license information
4. Add meaningful descriptions
5. Test builds before committing
6. Update this README with any changes

## Resources

- [NixOS buildNpmPackage documentation](https://nixos.org/manual/nixpkgs/stable/#javascript-tool-specific)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [Nix Prefetch Tools](https://nixos.org/manual/nixpkgs/stable/#chap-pkgs-fetchers)
