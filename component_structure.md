# Standardized Migration Pattern File Structure

This document defines the standardized structure for all migration pattern files (RAD component migration from NET4 to NET6).

## Standard Structure Template

```markdown
---
description: "Migration pattern for [NET4 Component] → [NET6 Component]"
alwaysApply: false
---

# [NET4 Component] → [NET6 Component]

- NET4: `[NET4 Namespace]`
- NET6: `[NET6 Namespace]`

## When to use
- [Use case 1]
- [Use case 2]
- [Use case 3]

[OPTIONAL: Layout Requirements]
## Layout Requirements
- [Specific layout requirements if applicable]

[OPTIONAL: NET6 Direct Public API]
## NET6 Direct Public API

### Component-Specific Properties
- [Property name] - [Description] (`[Type]`)
- ...

### Editor Required Properties
- [Property name] - **EditorRequired** - [Description] (`[Type]`)
- ...

### Inherited Properties
- Properties from `[Base Class]` - See @[reference].mdc
  - [Property name] - [Description]
  - ...

### Direct Methods
- [Method name]() - [Description] (`[Return Type]`, [access modifier])
- ...

[REQUIRED: Parameter/Property Mapping]
## Parameter mapping (NET4 → NET6)
- [NET4 Property] → [NET6 Property/Mapping] [Optional: - See @reference.mdc]
- ...

[OPTIONAL: Method signature mapping]
## Method signature mapping (NET4 → NET6)
- [NET4 signature] → [NET6 signature]
- Parameter order: [changes]
- Return: [NET4 return] → [NET6 return]

[OPTIONAL: Value mappings]
## Value mappings
- [NET4 Value/Enum] → [NET6 Value/Enum]
- ...

[OPTIONAL: Resource access pattern]
## Resource access pattern
- `[NET4 pattern]` → `[NET6 pattern]`
- ...

[OPTIONAL: Bindings]
## Bindings
- [Binding description/requirements]

[OPTIONAL: Event handlers]
## Event handlers
- NET4: `[NET4 pattern]`
- NET6: `[NET6 pattern]`

[OPTIONAL: Special sections]
## [Component-specific section name]
- [Content]

[OPTIONAL: Examples - ONLY if original file has examples]
## Examples
[Code examples if they exist in original]

[REQUIRED: Anti-patterns]
## Anti-patterns
- [Anti-pattern 1]
- [Anti-pattern 2]
- ...

[OPTIONAL: References]
## References
- [Reference links if applicable]
```

## Section Order Guidelines

The recommended section order is:

1. **Frontmatter** (required)
   - `description`: Brief description of the migration pattern
   - `alwaysApply`: Always set to `false`

2. **Title with NET4 → NET6 mapping** (required)
   - Shows NET4 namespace and NET6 namespace

3. **When to use** (required)
   - List of use cases for the component

4. **Layout Requirements** (optional)
   - Only include if component has specific layout requirements (e.g., must be wrapped in R_ItemLayout)

5. **NET6 Direct Public API** (optional)
   - Include for components with specific public APIs
   - Subsections: Component-Specific Properties, Editor Required Properties, Inherited Properties, Direct Methods

6. **Parameter mapping** (required)
   - Maps NET4 properties/parameters to NET6 equivalents
   - Use "Parameter mapping" for property-based components
   - Use "Method signature mapping" for method-based components

7. **Method signature mapping** (optional)
   - Only for method-based components (e.g., R_RadMessageBox)

8. **Value mappings** (optional)
   - Enum/value mappings between NET4 and NET6

9. **Resource access pattern** (optional)
   - Resource access pattern changes

10. **Bindings** (optional)
    - Component binding requirements

11. **Event handlers** (optional)
    - Event handling patterns with NET4 and NET6 examples

12. **Component-specific sections** (optional)
    - Any component-specific sections (e.g., "Tab content", "Alignment mappings", "Styling", "Migration pattern")

13. **Examples** (optional)
    - Only include if the original file had examples
    - Include NET4 and NET6 code examples

14. **Anti-patterns** (required)
    - List of common mistakes to avoid

15. **References** (optional)
    - Reference links to documentation files

## Key Standardization Rules

1. **Consistent section order**: Follow the order outlined above for consistency across all files
2. **Terminology**: Use "Parameter mapping" consistently for property-based components, or "Method signature mapping" for method-based components
3. **Inherited Properties**: Always reference base classes with `@reference.mdc` format
4. **Examples**: Only include if the original file had examples - do not add examples if they weren't in the original
5. **Cross-references**: Use consistent `@reference.mdc` format for all cross-references
6. **Optional sections**: Mark sections as optional in the template, but remove the [OPTIONAL] markers in actual files

## Subsections Guidelines

### NET6 Direct Public API Structure

When including the NET6 Direct Public API section, organize it as follows:

1. **Editor Required Properties** (if applicable)
   - Properties marked with `**EditorRequired**` attribute
   - These are mandatory properties that must be set

2. **Component-Specific Properties** (if applicable)
   - Properties unique to this component
   - Format: `[Property name] - [Description] ([Type])`

3. **Inherited Properties** (if applicable)
   - Group by base class
   - Reference base class documentation with `@reference.mdc`
   - List key inherited properties with descriptions

4. **Direct Methods** (if applicable)
   - Public methods available on the component
   - Format: `[Method name]() - [Description] ([Return Type], [access modifier])`

## Notes

- All sections marked as [OPTIONAL] should only be included if relevant to the specific component
- Sections marked as [REQUIRED] must be present in every migration pattern file
- Maintain consistency in formatting, terminology, and cross-reference style across all files
- When in doubt, refer to existing standardized files as reference examples
