# Standardized Enum Migration Pattern File Structure

This document defines the standardized structure for all enum migration pattern files (enum migration from NET4 to NET6).

## Standard Structure Template

```markdown
---
description: "Migration pattern for [NET4 Enum] → [NET6 Enum]"
alwaysApply: false
---

# [NET4 Enum] → [NET6 Enum]

- NET4: `[NET4 namespace/class].[EnumName]`
- NET6: `[NET6 namespace].[EnumName]`

## Enum type mapping
- NET4: `[NET4 enum type]` → NET6: `[NET6 enum type]`
- [Additional namespace details if needed]

## Enum value mapping
- `[NET4 value]` → `[NET6 value]`
- [Note any special cases: missing values, renamed values, etc.]

[OPTIONAL: Property mapping]
## Property mapping
- NET4: `[NET4 property]` → NET6: `[NET6 property]`
- [Only if enum is accessed via a property]

[OPTIONAL: Event handler parameter migration]
## Event handler parameter migration
- NET4: `[NET4 parameter pattern]` → NET6: `[NET6 parameter pattern]`
- [Only if enum is used in event handlers]

[OPTIONAL: Usage examples]
## Usage examples
### NET4 VB.NET
```vb
[NET4 code example]
```

### NET6 C#
```csharp
[NET6 code example]
```

[REQUIRED: Notes]
## Notes
- [Migration note 1]
- [Migration note 2]
- [Special considerations]

[OPTIONAL: References]
## References
- [Reference link 1]
- [Reference link 2]
```

## Section Order

1. **Frontmatter** (required)
   - `description`: Brief description of the migration pattern
   - `alwaysApply`: Always set to `false`

2. **Title with NET4 → NET6 mapping** (required)
   - Shows NET4 and NET6 enum locations

3. **Enum type mapping** (required)
   - Maps NET4 enum type to NET6 enum type
   - Include full namespace when applicable

4. **Enum value mapping** (required)
   - Maps each enum value from NET4 to NET6
   - Note any missing or renamed values

5. **Property mapping** (optional)
   - Only include if enum is accessed via a component property
   - Maps property access patterns

6. **Event handler parameter migration** (optional)
   - Only include if enum is used in event handler parameters
   - Maps parameter access patterns

7. **Usage examples** (optional)
   - Include NET4 and NET6 code examples side-by-side
   - Only include if examples clarify migration patterns

8. **Notes** (required)
   - Migration-specific considerations
   - Special cases or gotchas

9. **References** (optional)
   - Links to documentation files

## Key Rules

1. **Consistent section order**: Follow the order outlined above
2. **Enum value mapping**: Always list all values, even if unchanged
3. **Notes**: Include special cases (missing values, renamed values, access pattern changes)
4. **Examples**: Only include if they clarify non-obvious migration patterns
5. **Cross-references**: Use `@reference.mdc` format when referencing related patterns

