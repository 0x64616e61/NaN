# Documentation Agent Task List

## PRIMARY TASK: Nested Documentation with Verification

Following RULES.md: "Task Pattern: Understand → Plan (with parallelization analysis) → TodoWrite(3+ tasks) → Execute → Track → Validate"

### DELEGATION HIERARCHY

Each sub-agent MUST spawn 3 verification agents and operate in nix-shell.

## TODO TASKS

### 1. Technical Implementation Documentation Agent
**STATUS**: ⏳ PENDING
**AGENT INSTRUCTIONS**:
"Document technical implementation details. Spawn 3 agents to:
- Gather evidence using: nix-shell -p ripgrep fd git --run 'rg -n thermald modules/'
- Verify thermal management findings
- Cross-reference power configuration
All operations in nix-shell. Follow RULES.md delegate patterns."

### 2. Integration Patterns Documentation Agent
**STATUS**: ⏳ PENDING
**AGENT INSTRUCTIONS**:
"Document integration patterns. Spawn 3 agents to:
- Gather evidence using: nix-shell -p ripgrep fd git --run 'fd default.nix modules/ | head -10'
- Verify module import patterns
- Cross-reference namespace structures
All operations in nix-shell. Follow RULES.md delegate patterns."

### 3. Custom vs Native Evidence Agent
**STATUS**: ⏳ PENDING
**AGENT INSTRUCTIONS**:
"Document custom vs native evidence. Spawn 3 agents to:
- Gather evidence using: nix-shell -p ripgrep fd git --run 'rg -n custom\\.system modules/'
- Verify custom option definitions
- Cross-reference native Nix patterns
All operations in nix-shell. Follow RULES.md delegate patterns."

### 4. Configuration Analysis Agent
**STATUS**: ⏳ PENDING
**AGENT INSTRUCTIONS**:
"Document configuration analysis. Spawn 3 agents to:
- Gather evidence using: nix-shell -p ripgrep fd git --run 'rg -n hydenix flake.nix'
- Verify flake configuration structure
- Cross-reference hardware detection logic
All operations in nix-shell. Follow RULES.md delegate patterns."

### 5. Migration Path Documentation Agent
**STATUS**: ⏳ PENDING
**AGENT INSTRUCTIONS**:
"Document migration paths. Spawn 3 agents to:
- Gather evidence using: nix-shell -p ripgrep fd git --run 'rg -n thermal modules/'
- Verify thermal vs power conflicts
- Cross-reference alternative approaches
All operations in nix-shell. Follow RULES.md delegate patterns."

## COMPILATION TASK

### 6. Master Documentation Compiler
**STATUS**: ⏳ PENDING
**DEPENDENCIES**: Tasks 1-5 complete
**INSTRUCTIONS**: "Compile all nested agent findings into comprehensive technical documentation report. Evidence-based claims only. Professional language per RULES.md."

## VALIDATION PATTERN

Each agent MUST:
1. Use nix-shell for ALL operations
2. Spawn exactly 3 verification sub-agents
3. Provide evidence-based findings only
4. Follow RULES.md delegation patterns
5. Report verification chain results

## EXECUTION ORDER
- Parallel: Tasks 1-5 (independent evidence gathering)
- Sequential: Task 6 (depends on 1-5 completion)
- Validation: Continuous verification through nested agents