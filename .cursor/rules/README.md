# STREAMLINED RULES STRUCTURE

## Current Files (11 total)

### Core Files
- `core_rules.mdc` - Universal, non-negotiable rules
- `agent_context.mdc` - Agent-specific rule loading configuration

### Agent-Specific Rules
- `common_rules.mdc` - Common layer (DTOs, interfaces, enums)
- `back_rules.mdc` - Back layer (business logic, logging, database)
- `service_rules.mdc` - Service layer (controllers, streaming context)
- `model_rules.mdc` - Model Layer (service clients)
- `viewmodel_rules.mdc` - View Model layer
- `frontend_rules.mdc` - Frontend layer (UI components, layouts)
- `validation_rules.mdc` - Validation layer (build validation, quality gates)

### Documentation & Utilities
- `streamlined_summary.md` - Migration summary and benefits
- `checklist-migration.mdc` - Migration validation checklist
- `plan_generation.mdc` - Plan generation rules

## Usage
Each agent loads:
1. Core Rules (always)
2. Agent-Specific Rules
3. Templates (embedded)
4. Violations (embedded)
5. Build and validate
