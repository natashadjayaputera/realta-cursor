---
name: "ToCSharpFront"
model: "claude-4.5-sonnet"
description: "Convert VB.NET WinForms/WPF front-end into modern C# Blazor front-end projects `{ProgramName}.razor` / `{ProgramName}.razor.cs` (.NET 6)."
icon: "🟣"
trigger: "front"
color: "purple"
actions:
  auto_apply_edits: false
  auto_run: true
  auto_fix_errors: true
tools:
  all: true
  search:
    codebase: true
    web: false
    fetch_rules: true
    read_file: true
  edit:
    edit_and_reapply: true
    create_file: true
    delete_file: false
  run:
    terminal: false
---
# ToCSharpFront

## Overview
Agent purpose: Convert VB.NET (.NET Framework 4) WinForms/WPF front-end code into C# (.NET 6) Blazor components (`{ProgramName}.razor` and `{ProgramName}.razor.cs`). Preserve UI layout and behavior, migrate component patterns, and follow strict dependency injection and using statement rules.

## Prerequisites
- `{ProgramName}ViewModel.cs` must exist in `/net6/**/FRONT/{ProgramName}Model/VMs/` before conversion
- If ViewModel doesn't exist, inform user to create it first via `ToCSharpViewModel` agent

## Instructions (Step-by-Step)

### Step 1: Discover Programs
- List all program names from NET4 VB files in `/net4/**/Front/{ProgramName}*/**/*.vb`
- Extract program names from file paths/filenames (e.g., `FAB00200` from `FAB00200.vb`)
- **Action**: Ask user to select which program name to convert

### Step 2: Analyze VB File
- Read the chosen `{ProgramName}.vb` file
- Identify all referenced program names from:
  - `R_RunForm()` calls
  - `R_PopUp()` calls
  - `R_Before_Open_Form()` calls
  - Other navigation methods

### Step 3: Handle Program References
For each referenced program name found:
- Extract first 6 characters of chosen program name (e.g., `FAM00100` → `FAM001`)
- Check if referenced program starts with same 6-character prefix
- **If matches** (e.g., `FAM0010001`, `FAM00110` start with `FAM001`):
  - Create empty partial class: `public partial class {ReferencedProgramName} : R_Page { }`
  - Place in appropriate location so it can be referenced
- **If doesn't match** (e.g., `GSL00100` doesn't start with `FAM001`):
  - Add comment: `// TODO: implement navigation to {ReferencedProgramName} manually`

### Step 4: Identify ViewModel
- Analyze VB file to determine required ViewModel
- Look for corresponding `{ProgramName}ViewModel.cs` in `/net6/**/FRONT/{ProgramName}Model/VMs/`
- **If exists**: Read the ViewModel file to understand data structure
- **If missing**: Inform user that ViewModel must be created first via `ToCSharpViewModel` agent

### Step 5: Identify Components and Patterns
- Scan VB file to identify NET4 components/patterns used:
  - `R_LookUp`, `R_Conductor`, `R_FormBase`, `R_Grid`, etc.
  - Create list of all components found

### Step 6: Fetch Migration Patterns
- Fetch migration-patterns from `.cursor/rules/front/components/migration-patterns/`
- **Fetch ONLY** patterns for components found in Step 5
- Pattern naming: `{componentname}.mdc` (e.g., `R_LookUp` → `r_lookup.mdc`)
- **Rule**: Always fetch pattern file first, never guess

### Step 7: Fetch Component Rules (if needed)
- Fetch specific component rules from `.cursor/rules/front/components/net6/`
- **Fetch ONLY** when NET6 component is used without migration
- Pattern naming: `{componentname}.mdc` (e.g., `R_Page` → `r_page.mdc`)

### Step 8: Fetch Documentation (if needed)
- Fetch documentation from `.cursor/docs/net6`
- **Fetch ONLY** when specific component API details are needed

### Step 9: Convert to Blazor
- Convert VB file to `{ProgramName}.razor` and `{ProgramName}.razor.cs`
- Follow migration-patterns exactly as fetched
- Create layout based on provided image (if available)
- Use `R_BlazorFrontEnd.Controls` components

### Step 10: Build and Report
- Build the project
- **Do NOT** fix errors automatically
- Generate warnings and errors report following `@build_report_format.mdc`

## Critical Rules

### Dependency Injection (MANDATORY)
- **ALL** `[Inject]` attributes MUST be in `.razor.cs` code-behind files, **NEVER** in `.razor` files
- **NEVER** use `@inject` directives in `.razor` files
- **Pattern**: `[Inject] private IType PropertyName { get; set; } = default!;`
- **Required injections** (in `.razor.cs` only):
  - `IClientHelper ClientHelper` (NOT in ViewModel)
  - `R_ILocalizer Localizer` (NOT in `.razor` file)
  - `R_MessageBoxService MessageBoxService` (NOT in `.razor` file)
- **Reference**: See `@front_dependency_injection.mdc` for examples

### Using Statements (MANDATORY)
- **ALL** `@using` statements MUST be in `_Imports.razor` file, **NEVER** in `.razor` files
- Use EXACT minimal required using statements. See `@front_imports_and_usings.mdc` and `@front_razor_cs_using_statements.mdc`

### State Management
- **UI state**: Must be in `.razor.cs` code-behind
- **Data state**: Must be in ViewModel (non-UI state only)
- **Data validation**: Only in ViewModel, NOT in `.razor.cs`

### Workflow
- Work one program at a time
- Ask user before proceeding to next program

## Context (Fetch On-Demand Only)

### Migration-Patterns
- **Location**: `.cursor/rules/front/components/migration-patterns/`
- **Fetch Strategy**: Fetch ONLY patterns for components found in VB file
- **Pattern Naming**: `{componentname}.mdc` (e.g., `R_LookUp` → `r_lookup.mdc`, `R_FormBase` → `r_formbase.mdc`)
- **Rule**: Always fetch pattern file first, never guess

### Specific Component Rules
- **Location**: `.cursor/rules/front/components/net6/`
- **Fetch Strategy**: Fetch ONLY when NET6 component is used without migration
- **Pattern Naming**: `{componentname}.mdc` (e.g., `R_Page` → `r_page.mdc`, `R_Label` → `r_label.mdc`)

### Documentation
- **Location**: `.cursor/docs/net6`
- **Fetch Strategy**: Fetch ONLY when specific component API details are needed

### Rules
- **Fetch Strategy**: Fetch `.mdc` rules matching `*ToCSharpFront*` only when needed

### Checklists
- **Fetch Strategy**: Fetch `*MigrationChecklist*` / `*FrontMigrationChecklist*` only at the end for verification

## CSProj (Front Project Requirements)
```xml
<Project Sdk="Microsoft.NET.Sdk.Razor">
	<PropertyGroup>
		<TargetFramework>net6.0</TargetFramework>
		<LangVersion>10.0</LangVersion>
		<Nullable>enable</Nullable>
		<ImplicitUsings>disable</ImplicitUsings>
	</PropertyGroup>

	<ItemGroup>
		<SupportedPlatform Include="browser" />
	</ItemGroup>

	<ItemGroup>
		<PackageReference Include="Microsoft.AspNetCore.Components.Web" Version="6.0.36" />
	</ItemGroup>

	<ItemGroup>
		<Reference Include="R_APICommonDTO">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_APICommonDTO.dll</HintPath>
		</Reference>
		<Reference Include="R_CommonFrontBackAPI">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_CommonFrontBackAPI.dll</HintPath>
		</Reference>
		<Reference Include="R_BlazorFrontEnd">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_BlazorFrontEnd.dll</HintPath>
		</Reference>
		<Reference Include="R_BlazorFrontEnd.Controls">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_BlazorFrontEnd.Controls.dll</HintPath>
		</Reference>
		<Reference Include="BlazorClientHelper">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Menu\BlazorClientHelper.dll</HintPath>
		</Reference>
		<Reference Include="R_LockingFront">
			<HintPath>..\..\..\..\SYSTEM\SOURCE\LIBRARY\Front\R_LockingFront.dll</HintPath>
		</Reference>
	</ItemGroup>

	<ItemGroup>
		<ProjectReference Include="..\{ProgramName}Model\{ProgramName}Model.csproj" />
		<ProjectReference Include="..\{ProgramName}FrontResources\{ProgramName}FrontResources.csproj" />
	</ItemGroup>
</Project>
```

## Outputs / Deliverables

* `.razor` and `.razor.cs` files per UI screen, following migration patterns
* Component library usage updated to `R_BlazorFrontEnd*`
* Migration notes describing lifecycle and binding changes
* Build report with warnings and errors (following `@build_report_format.mdc`)

## Usage (Cursor)

* Type `/ToCSharpFront` (custom commands)
* Copy: `convert {ProgramName} .NET4 VB Forms to {ProgramName} Blazor components. Before starting the conversion, load and apply the migration-patterns. While analyzing the .NET4 source files, detect any conflicts or deviations from the migration-patterns. If conflicts are found, dynamically update and adjust the migration plan to fully comply with the migration-patterns before proceeding with code generation. ProgramName: ... and start with page: ...`