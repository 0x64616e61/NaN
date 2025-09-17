# Quality Validation Tasks - Primary Agent 3/5

## Critical Context
- Working in production branch (as per git status)
- Modified files: CLAUDE.md, battery-optimization.nix, power/default.nix
- Repository: Personal NixOS config for GPD Pocket 3 (61 total modules)
- RULES.md mandates: Spawn 5 sub-agents, each spawns 3 validation agents = 15+ verification points

## Primary Quality Validation Tasks

### TODO 1: Code Quality Validation Sub-Agent
- **Scope**: All modified files + module structure compliance
- **Focus**: Nix syntax, option patterns, namespace adherence
- **Delegation**: Spawn 3 nested agents for syntax/patterns/standards
- **Environment**: All operations in nix-shell
- **Verification**: Cross-check findings with other sub-agents

### TODO 2: Integration Testing Sub-Agent
- **Scope**: System rebuild testing, flake validation, hardware compatibility
- **Focus**: Test configurations without breaking system
- **Delegation**: Spawn 3 nested agents for build/test/rollback
- **Environment**: All operations in nix-shell with --impure flags
- **Verification**: Validate against known working state

### TODO 3: Pattern Compliance Sub-Agent
- **Scope**: Module organization, naming conventions, option structure
- **Focus**: custom.system.* and custom.hm.* namespace compliance
- **Delegation**: Spawn 3 nested agents for system/hm/aggregation patterns
- **Environment**: All operations in nix-shell
- **Verification**: Ensure consistency across all 61 modules

### TODO 4: Documentation Accuracy Sub-Agent
- **Scope**: CLAUDE.md accuracy, architecture alignment, command validation
- **Focus**: Documentation matches actual implementation
- **Delegation**: Spawn 3 nested agents for content/commands/architecture
- **Environment**: All operations in nix-shell for command verification
- **Verification**: Test all documented commands and validate claims

### TODO 5: Cross-Agent Consensus Sub-Agent
- **Scope**: Synthesize findings from all other sub-agents
- **Focus**: Identify conflicts, gaps, quality risks
- **Delegation**: Spawn 3 nested agents for synthesis/conflict-resolution/reporting
- **Environment**: All operations in nix-shell for final validation
- **Verification**: Generate comprehensive quality report with nested redundancy

## Nested Redundancy Pattern
Each sub-agent follows this pattern:
```
Sub-Agent X → Spawn 3 agents:
├── Agent 1: Test in nix-shell
├── Agent 2: Verify independently
└── Agent 3: Cross-check results
```

## Expected Deliverables
- 5 detailed sub-agent reports
- 15+ nested validation points
- Comprehensive quality assessment
- Risk identification and mitigation recommendations
- Cross-validated findings consensus