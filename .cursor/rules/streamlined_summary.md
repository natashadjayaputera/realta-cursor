# STREAMLINED RULES STRUCTURE

## Problem Solved
- **Before**: 45+ rules with conflicts and ambiguity
- **After**: 6 agent-specific rule sets with clear hierarchy

## New Structure

### 1. Core Rules (Universal)
- Documentation first
- Project structure
- Business logic preservation
- Build validation
- Error handling

### 2. Agent-Specific Rules
- **Common**: DTOs, interfaces, enums
- **Back**: Business logic, logging, database
- **Service**: Controllers, streaming context
- **Model**: Service clients, ViewModels
- **Frontend**: UI components, layouts
- **Validation**: Build validation, quality gates

### 3. Agent Context Configuration
- Clear rule loading per agent
- Conflict resolution hierarchy
- Simplified decision flow

## Benefits

### Reduced Ambiguity
- Each agent has focused, relevant rules
- Clear priority order eliminates conflicts
- Specific escalation path

### Improved Efficiency
- Agents load only relevant rules
- Faster decision-making
- Less analysis paralysis

### Better Maintainability
- Rules organized by responsibility
- Easier to update specific areas
- Clear separation of concerns

## Usage

### For Each Agent
1. Load Core Rules (always)
2. Load Agent-Specific Rules
3. Apply Templates
4. Check Violations
5. Build and validate

### Conflict Resolution
1. Core Rules → Agent Rules → Templates → Ask User
2. Never invent patterns
3. Always ask when unclear

## Migration Path

### Phase 1: Implement New Structure
- Deploy agent-specific rule files
- Update agent context configuration
- Test with one agent

### Phase 2: Validate Effectiveness
- Monitor rule conflicts
- Measure decision speed
- Gather agent feedback

### Phase 3: Optimize
- Refine agent-specific rules
- Adjust conflict resolution
- Fine-tune escalation paths

## Files Created
- `core_rules.mdc` - Universal rules
- `common_rules.mdc` - Common layer rules
- `back_rules.mdc` - Back layer rules
- `service_rules.mdc` - Service layer rules
- `model_rules.mdc` - Model layer rules
- `viewmodel_rules.mdc` - View Model layer rules
- `frontend_rules.mdc` - Frontend layer rules
- `validation_rules.mdc` - Validation rules
- `agent_context.mdc` - Context configuration
